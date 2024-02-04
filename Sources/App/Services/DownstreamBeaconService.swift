import BeaconAPI
import Foundation
import NIOConcurrencyHelpers
import Vapor

class DownstreamBeaconService {
    // MARK: - Properties

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private let app: Application

    private let beaconNodeConnections: NIOLockedValueBox<[BeaconNodeConnection]> = .init([])

    enum Error: Swift.Error {
        case beaconNodeEndpointsMalformed(message: String)
    }

    // MARK: - Initialization

    init(app: Application) throws {
        self.app = app

        try setup()
    }

    // MARK: - Helpers

    /// Warn: Should only ever be used once.
    private func setup() throws {
        guard let endpointsString = Environment.get("BEACON_NODE_ENDPOINTS") else {
            throw Error
                .beaconNodeEndpointsMalformed(
                    message: "BEACON_NODE_ENDPOINTS must be set as a comma separated list of beacon node URLs"
                )
        }

        app.logger.info("Loading BEACON_NODE_ENDPOINTS")

        let endpoints = try endpointsString.split(separator: ",").map { String($0) }.map {
            guard let url = URL(string: $0) else {
                throw Error.beaconNodeEndpointsMalformed(message: "BEACON_NODE_ENDPOINTS provided url is invalid")
            }

            return url
        }

        app.logger.info("Loaded \(endpoints.count) beacon node endpoints.")

        var beaconNodeConnections: [BeaconNodeConnection] = []
        for endpoint in endpoints {
            beaconNodeConnections.append(BeaconNodeConnection(
                app: app,
                beaconNodeUrl: endpoint,
                eventCallback: eventResponse(event:data:decodedData:)
            ))
        }

        self.beaconNodeConnections.withLockedValue {
            $0 = beaconNodeConnections
        }
    }

    private let eventCounter = NIOLockedValueBox(0)
    private func eventResponse(
        event _: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        data _: String,
        decodedData _: any Codable & Hashable & Sendable
    ) {
        // print(event)
        // print(data)
        // print(decodedData)
        eventCounter.withLockedValue {
            $0 += 1
            if $0 % 1000 == 0 {
                self.app.logger.warning("Received \($0) events to date.")
            }
        }
    }

    // MARK: - Public API
}

struct DownstreamBeaconServiceKey: StorageKey {
    typealias Value = DownstreamBeaconService
}

extension Application {
    var downstreamBeaconService: DownstreamBeaconService! {
        get {
            storage[DownstreamBeaconServiceKey.self]
        }
        set {
            storage[DownstreamBeaconServiceKey.self] = newValue
        }
    }
}
