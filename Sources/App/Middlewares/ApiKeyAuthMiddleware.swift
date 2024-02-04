import Foundation
import Vapor

// private struct IdOnly: Codable {
//     let id: JSONRPCId
// }

// struct MappedRedisCachedProject {
//     let project: Project

//     let corsOrigins: [String: Bool]
//     let allowedIps: [String: Bool]
//     let bannedIps: [String: Bool]

//     init(project: Project) {
//         self.project = project

//         var corsOrigins = [String: Bool]()
//         for cors in project.parseCorsOrigins() {
//             corsOrigins[cors.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] = true
//         }
//         self.corsOrigins = corsOrigins

//         var allowedIps = [String: Bool]()
//         for ip in project.parseCorsOrigins() {
//             allowedIps[ip.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] = true
//         }
//         self.allowedIps = allowedIps

//         var bannedIps = [String: Bool]()
//         for ip in project.parseCorsOrigins() {
//             bannedIps[ip.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] = true
//         }
//         self.bannedIps = bannedIps
//     }
// }

// struct MappedRedisCachedApiKeyUser {
//     let user: User
//     let redisUser: RedisCachedApiKeyUser
//     let project: MappedRedisCachedProject?

//     init(_ redisUser: RedisCachedApiKeyUser) {
//         user = redisUser.user
//         self.redisUser = redisUser
//         if let project = redisUser.project {
//             self.project = .init(project: project)
//         } else {
//             project = nil
//         }
//     }
// }

// private struct UserKey: StorageKey {
//     typealias Value = MappedRedisCachedApiKeyUser
// }

// struct ApiKeyAuthMiddleware: Middleware, SimpleResponderMiddleware {
//     private let jsonDecoder = JSONDecoder()
//     private let jsonEncoder = JSONEncoder()

//     private let app: Application

//     init(app: Application) {
//         self.app = app
//     }

//     static func setApiKeyUserToStorage(storage: SimpleStorageHolder, apiKeyUser: MappedRedisCachedApiKeyUser) {
//         storage.storage[UserKey.self] = apiKeyUser
//     }

//     func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
//         let promise = request.eventLoop.makePromise(of: Response.self)

//         promise.completeWithTask {
//             // Authenticate or fail
//             let (user, error) = await genericApiKeyChecker(apiKey: request.parameters.get("apiKey"))

//             guard let user, error == nil else {
//                 return try await request.body.collect(max: ProxyConnectionConstants.MAX_REQUEST_SIZE_BYTES)
//                     .flatMapWithEventLoop { bytes, eventLoop -> EventLoopFuture<Response> in
//                         var id: JSONRPCId = .nullValue
//                         if let bytes, let idOnly = try? jsonDecoder.decode(IdOnly.self, from: bytes) {
//                             id = idOnly.id
//                         }

//                         let errorPromise = eventLoop.makePromise(of: Response.self)
//                         errorPromise.succeed(Response.jsonRPCError(id: id, error: error ?? .genericServerError))
//                         return errorPromise.futureResult
//                     }.get()
//             }

//             // Store User in Request
//             request.storage[UserKey.self] = .init(user)

//             // Continue
//             return try await next.respond(to: request).get()
//         }

//         return promise.futureResult
//     }

//     func simpleRespond(
//         to request: Data,
//         params: [String: Any],
//         headers: [String: Any],
//         storage: SimpleStorageHolder,
//         chainingTo next: SimpleResponder
//     ) -> EventLoopFuture<Data> {
//         let promise = app.eventLoopGroup.next().makePromise(of: Data.self)

//         promise.completeWithTask {
//             // Authenticate or fail
//             let (user, error) = await genericApiKeyChecker(apiKey: params["apiKey"] as? String)

//             guard let user, error == nil else {
//                 var id: JSONRPCId = .nullValue
//                 if let idOnly = try? jsonDecoder.decode(IdOnly.self, from: request) {
//                     id = idOnly.id
//                 }

//                 return (try? jsonEncoder.encode(JSONRPCError.genericServerError.jsonRPCErrorResponse(id: id))) ??
//                 Data()
//             }

//             // Store User in Request
//             storage.storage[UserKey.self] = .init(user)

//             // Continue
//             return try await next.simpleRespond(to: request, params: params, headers: headers, storage:
//             storage).get()
//         }

//         return promise.futureResult
//     }

//     // MARK: - Helpers

//     /// Returns an error response if api key auth is not succesful, a user otherwise.
//     private func genericApiKeyChecker(apiKey: String?) async -> (user: RedisCachedApiKeyUser?, error: JSONRPCError?)
//     {
//         guard let apiKey, let user = try? await app.userService.fetchUserCached(apiKey: apiKey) else {
//             return (user: nil, error: .invalidApiKey)
//         }

//         return (user: user, error: nil)
//     }
// }

// extension SimpleStorageHolderRepresentable {
//     var apiKeyUser: MappedRedisCachedApiKeyUser? {
//         storage[UserKey.self]
//     }

//     func forceApiKeyUser() throws -> MappedRedisCachedApiKeyUser {
//         if let user = apiKeyUser {
//             return user
//         }

//         throw Abort(.internalServerError)
//     }
// }
