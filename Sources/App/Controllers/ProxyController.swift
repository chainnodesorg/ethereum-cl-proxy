import BeaconAPI
import Foundation
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import OpenAPIURLSession
import Vapor

struct ProxyController: RouteCollection {
    private let jsonEncoder = JSONEncoder()

    private let app: Application

    init(app: Application) {
        self.app = app
    }

    func boot(routes: RoutesBuilder) throws {
        let httpClient = HTTPClient(configuration: .init(
            connectionPool: HTTPClient.Configuration.ConnectionPool(
                idleTimeout: .seconds(60),
                concurrentHTTP1ConnectionsPerHostSoftLimit: 5000
            ),
            decompression: .enabled(limit: .ratio(100_000))
        ))
        let client = BeaconAPI.Client(
            serverURL: URL(string: "http://host.docker.internal:5051")!,
            transport: AsyncHTTPClientTransport(configuration: .init(client: httpClient, timeout: .seconds(60)))
        )

        routes.group("eth") { ethBuilder in
            ethBuilder.group("v1") { ethV1Builder in
                ethV1Builder.get("beacon", "genesis") { _ in
                    let genesis = try await client.getGenesis()

                    let jsonResponse = try jsonEncoder.encode(genesis.ok.body.json)

                    return Response(
                        status: .ok,
                        headers: HTTPHeaders([("Content-Type", "application/json")]),
                        body: .init(data: jsonResponse)
                    )
                }

                ethV1Builder.get("events") { _ in
                    let genesis = try await client.getGenesis()

                    let jsonResponse = try jsonEncoder.encode(genesis.ok.body.json)

                    let events = try await client.eventstream(query: .init(topics: [
                        .head,
                        .block,
                        .attestation,
                        .voluntary_exit,
                        // Seems to be removed since Capella
                        // .bls_to_execution_change,
                        .finalized_checkpoint,
                        .chain_reorg,
                        .contribution_and_proof,
                        // Not necessary for clients to support
                        // .light_client_finality_update,
                        // .light_client_optimistic_update,
                        .payload_attributes,
                    ]), headers: .init(accept: [.init(contentType: .text_event_hyphen_stream)]))

                    let stream = try events.ok.body.text_event_hyphen_stream.asDecodedServerSentEvents()
                    _ = app.eventLoopGroup.next().makeFutureWithTask {
                        for try await element in stream {
                            app.logger.critical("\(element.data!)")
                        }
                    }

                    return Response(
                        status: .ok,
                        headers: HTTPHeaders([("Content-Type", "application/json")]),
                        body: .init(data: jsonResponse)
                    )
                }
            }
        }
    }
}
