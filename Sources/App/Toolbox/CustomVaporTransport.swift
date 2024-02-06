import Atomics
import Foundation
import HTTPTypes
import NIOFoundationCompat
import OpenAPIRuntime
import Vapor

public final class CustomVaporTransport {
    /// A routes builder with which to register request handlers.
    var routesBuilder: any Vapor.RoutesBuilder

    var streamErrorClosure: (_ body: OpenAPIRuntime.HTTPBody, _ error: Error) -> Void

    /// Creates a new transport.
    /// - Parameter routesBuilder: A routes builder with which to register request handlers.
    public init(
        routesBuilder: any Vapor.RoutesBuilder,
        streamErrorClosure: @escaping (_ body: OpenAPIRuntime.HTTPBody, _ error: Error) -> Void
    ) {
        self.routesBuilder = routesBuilder
        self.streamErrorClosure = streamErrorClosure
    }
}

extension CustomVaporTransport: ServerTransport {
    public func register(
        _ handler: @Sendable @escaping (
            HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, OpenAPIRuntime.ServerRequestMetadata
        ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?),
        method: HTTPRequest.Method,
        path: String
    ) throws {
        routesBuilder.on(
            HTTPMethod(method),
            [PathComponent](path),
            body: .stream
        ) { vaporRequest in
            let request = try HTTPTypes.HTTPRequest(vaporRequest)
            let body = OpenAPIRuntime.HTTPBody(vaporRequest)
            let requestMetadata = try OpenAPIRuntime.ServerRequestMetadata(
                from: vaporRequest,
                forPath: path
            )
            let res = try await handler(request, body, requestMetadata)
            let response = Vapor.Response(response: res.0, body: res.1, streamErrorClosure: self.streamErrorClosure)
            if let contentLength = res.0.headerFields.first(where: { $0.name == .contentLength }) {
                response.headers.replaceOrAdd(name: .contentLength, value: contentLength.value)
            }
            return response
        }
    }
}

enum CustomVaporTransportError: Error {
    case unsupportedHTTPMethod(String)
    case duplicatePathParameter([String])
    case missingRequiredPathParameter(String)
    case multipleBodyIteration
}

extension [Vapor.PathComponent] {
    init(_ path: String) {
        self = path.split(
            separator: "/",
            omittingEmptySubsequences: true
        ).map { parameter in
            if parameter.first == "{", parameter.last == "}" {
                .parameter(String(parameter.dropFirst().dropLast()))
            } else {
                .constant(String(parameter))
            }
        }
    }
}

extension HTTPTypes.HTTPRequest {
    init(_ vaporRequest: Vapor.Request) throws {
        let headerFields: HTTPTypes.HTTPFields = .init(vaporRequest.headers)
        let method = try HTTPTypes.HTTPRequest.Method(vaporRequest.method)
        let queries = vaporRequest.url.query.map { "?\($0)" } ?? ""
        self.init(
            method: method,
            scheme: vaporRequest.url.scheme,
            authority: vaporRequest.url.host,
            path: vaporRequest.url.path + queries,
            headerFields: headerFields
        )
    }
}

extension OpenAPIRuntime.HTTPBody {
    convenience init(_ vaporRequest: Vapor.Request) {
        let contentLength = vaporRequest.headers.first(name: "content-length").map(Int.init)
        self.init(
            vaporRequest.body.map(\.readableBytesView),
            length: contentLength?.map { .known(numericCast($0)) } ?? .unknown,
            iterationBehavior: .single
        )
    }
}

extension OpenAPIRuntime.ServerRequestMetadata {
    init(from vaporRequest: Vapor.Request, forPath path: String) throws {
        try self.init(pathParameters: .init(from: vaporRequest, forPath: path))
    }
}

extension [String: Substring] {
    init(from vaporRequest: Vapor.Request, forPath path: String) throws {
        let keysAndValues = try [PathComponent](path).compactMap { component throws -> String? in
            guard case let .parameter(parameter) = component else {
                return nil
            }
            return parameter
        }.map { parameter -> (String, Substring) in
            guard let value = vaporRequest.parameters.get(parameter) else {
                throw CustomVaporTransportError.missingRequiredPathParameter(parameter)
            }
            return (parameter, Substring(value))
        }
        let pathParameterDictionary = try Dictionary(keysAndValues, uniquingKeysWith: { _, _ in
            throw CustomVaporTransportError.duplicatePathParameter(keysAndValues.map(\.0))
        })
        self = pathParameterDictionary
    }
}

extension Vapor.Response {
    convenience init(
        response: HTTPTypes.HTTPResponse,
        body: OpenAPIRuntime.HTTPBody?,
        streamErrorClosure: @escaping (_ body: OpenAPIRuntime.HTTPBody, _ error: Error) -> Void
    ) {
        self.init(
            status: .init(statusCode: response.status.code),
            headers: .init(response.headerFields),
            body: .init(body, streamErrorClosure: streamErrorClosure)
        )
    }
}

extension Vapor.Response.Body {
    init(
        _ body: OpenAPIRuntime.HTTPBody?,
        streamErrorClosure: @escaping (_ body: OpenAPIRuntime.HTTPBody, _ error: Error) -> Void
    ) {
        guard let body else {
            self = .empty
            return
        }
        /// Used to guard the body from being iterated multiple times.
        /// https://github.com/vapor/vapor/issues/3002
        let iterated = ManagedAtomic(false)
        let stream: @Sendable (any Vapor.BodyStreamWriter) -> Void = { writer in
            guard iterated.compareExchange(
                expected: false,
                desired: true,
                ordering: .relaxed
            ).exchanged else {
                _ = writer.write(.error(CustomVaporTransportError.multipleBodyIteration))
                return
            }
            _ = writer.eventLoop.makeFutureWithTask {
                do {
                    for try await chunk in body {
                        try await writer.write(.buffer(ByteBuffer(bytes: chunk))).get()
                    }
                    try await writer.write(.end).get()
                } catch {
                    streamErrorClosure(body, error)
                    try await writer.write(.error(error)).get()
                }
            }
        }
        switch body.length {
        case let .known(count):
            self = .init(stream: stream, count: Int(clamping: count))
        case .unknown:
            self = .init(stream: stream)
        }
    }
}

extension HTTPTypes.HTTPFields {
    init(_ headers: NIOHTTP1.HTTPHeaders) {
        self.init(headers.compactMap { name, value in
            guard let name = HTTPField.Name(name) else {
                return nil
            }
            return HTTPField(name: name, value: value)
        })
    }
}

extension NIOHTTP1.HTTPHeaders {
    init(_ headers: HTTPTypes.HTTPFields) {
        self.init(headers.map { ($0.name.rawName, $0.value) })
    }
}

extension HTTPTypes.HTTPRequest.Method {
    init(_ method: NIOHTTP1.HTTPMethod) throws {
        switch method {
        case .GET: self = .get
        case .PUT: self = .put
        case .POST: self = .post
        case .DELETE: self = .delete
        case .OPTIONS: self = .options
        case .HEAD: self = .head
        case .PATCH: self = .patch
        case .TRACE: self = .trace
        default: throw CustomVaporTransportError.unsupportedHTTPMethod(method.rawValue)
        }
    }
}

extension NIOHTTP1.HTTPMethod {
    init(_ method: HTTPTypes.HTTPRequest.Method) {
        switch method {
        case .get: self = .GET
        case .put: self = .PUT
        case .post: self = .POST
        case .delete: self = .DELETE
        case .options: self = .OPTIONS
        case .head: self = .HEAD
        case .patch: self = .PATCH
        case .trace: self = .TRACE
        default: self = .RAW(value: method.rawValue)
        }
    }
}
