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

    private let eventsCache = TimeBasedEquivalenceCache(keyExpirySeconds: 600)

    enum Error: Swift.Error {
        case beaconNodeEndpointsMalformed(message: String)
    }

    /// The callback used to notify upstream subscribers of new events.
    typealias UpstreamSubscriptionCallback = (
        _ event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        _ data: String
    ) -> Void

    /// Subscribers are saved here.
    /// event type -> event subscription ids in a dictionary and their callbacks.
    private let upstreamEventSubscriptions = NIOLockedValueBox<
        [BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload: [String: UpstreamSubscriptionCallback]]
    >([:])

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

    private func eventResponse(
        event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        data: String,
        decodedData: any Codable & Hashable & Sendable
    ) {
        let wasAddedBecauseNotSeenYet = eventsCache.addValueIfNotExists(decodedData)

        if wasAddedBecauseNotSeenYet {
            // Distribute the new event
            let allSubscriptions = upstreamEventSubscriptions.withLockedValue { $0[event] } ?? [:]
            for subscription in allSubscriptions {
                subscription.value(event, data)
            }
        }
    }

    // MARK: - Subscription APIs

    func subscribe(
        eventTypes: [BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload],
        callback: @escaping UpstreamSubscriptionCallback
    ) -> String {
        let subscriptionId = UUID().uuidString.sha3(.keccak256)

        upstreamEventSubscriptions.withLockedValue {
            for event in eventTypes {
                var oldSubscriptions = $0[event] ?? [:]
                oldSubscriptions[subscriptionId] = callback
                $0[event] = oldSubscriptions
            }
        }

        return subscriptionId
    }

    func unsubscribe(subscriptionId: String) {
        upstreamEventSubscriptions.withLockedValue {
            for key in $0.keys {
                var oldSubscriptions = $0[key] ?? [:]
                oldSubscriptions[subscriptionId] = nil
                $0[key] = oldSubscriptions
            }
        }
    }
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
