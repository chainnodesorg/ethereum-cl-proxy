import BeaconAPI
import Foundation
import NIOConcurrencyHelpers
import OpenAPIRuntime
import Vapor
import Web3

class DownstreamBeaconService {
    // MARK: - Properties

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private let app: Application

    // The actual downstream beacon node connections
    private let beaconNodeConnections: NIOLockedValueBox<[BeaconNodeConnection]> = .init([])

    // Excluded beacon nodes because of consens mismatches
    private let excludedBeaconNodeConnections: NIOLockedValueBox<[BeaconNodeConnection: Bool]> = .init([:])

    /// Cached events to prevent sending the same event to subscribers twice
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

    /// Used in the OpenAPI event streams to unsubscribe streams that have been cancelled client side
    /// DO NOT USE OUTSIDE OF DownstreamBeaconService and EXTENSTION OF IT
    let runningUpstreamBeaconNodeEventStreams: NIOLockedValueBox<[OpenAPIRuntime.HTTPBody: BeaconNodeEventStream]> =
        .init([:])

    // MARK: - Initialization

    init(app: Application) throws {
        self.app = app

        try setup()

        // Every second select consens information, even if no requests come in.
        app.eventLoopGroup.next().scheduleRepeatedTask(initialDelay: .seconds(1), delay: .seconds(1)) { _ in
            _ = self.healthyBeaconNodeConnections()
        }
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
            let beaconNodeConnection = BeaconNodeConnection(
                app: app,
                beaconNodeUrl: endpoint,
                eventCallback: { _, _, _ in }
            )
            beaconNodeConnection.eventCallback.withLockedValue {
                $0 = self.eventResponse(beaconNode: beaconNodeConnection)
            }

            beaconNodeConnections.append(beaconNodeConnection)
        }

        self.beaconNodeConnections.withLockedValue {
            $0 = beaconNodeConnections
        }
    }

    private func eventResponse(beaconNode: BeaconNodeConnection) -> (
        _ event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        _ data: String,
        _ decodedData: any Codable & Hashable & Sendable
    ) -> Void {
        { event, data, decodedData in
            if let beaconNodeExcluded = self.excludedBeaconNodeConnections.withLockedValue({ $0[beaconNode] }),
               beaconNodeExcluded
            {
                return
            }

            let copyOfDecodedData = decodedData
            let wasAddedBecauseNotSeenYet = self.eventsCache.addValueIfNotExists(copyOfDecodedData.hashValue)

            if wasAddedBecauseNotSeenYet {
                // Distribute the new event
                let allSubscriptions = self.upstreamEventSubscriptions.withLockedValue { $0[event] } ?? [:]
                for subscription in allSubscriptions {
                    subscription.value(event, data)
                }
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

    // MARK: - Health Checks

    private func healthyBeaconNodeConnections() -> [BeaconNodeConnection] {
        // Filter generally unhealthy node
        let healthyBeaconNodes = beaconNodeConnections.withLockedValue { $0 }
            .filter { $0.isHealthy(acceptableAge: .seconds(60)) }

        // Select beacon node status for calculations of consensus later

        var beaconNodesWithStatus = [
            (
                beaconNode: BeaconNodeConnection,
                status: (
                    syncing: BeaconAPI.Operations.getSyncingStatus.Output.Ok.Body.jsonPayload,
                    fork: BeaconAPI.Operations.getStateFork.Output.Ok.Body.jsonPayload,
                    genesis: BeaconAPI.Operations.getGenesis.Output.Ok.Body.jsonPayload
                )
            )
        ]()
        for beaconNode in healthyBeaconNodes {
            let status = beaconNode.chainStatus()
            guard let syncing = status.syncing, let fork = status.fork, let genesis = status.genesis else {
                continue
            }

            beaconNodesWithStatus.append((
                beaconNode: beaconNode,
                status: (syncing: syncing, fork: fork, genesis: genesis)
            ))
        }

        // Select consensus information from all nodes

        var beaconNodesWithStatusAndConvertedValues = [
            (
                beaconNode: BeaconNodeConnection,
                status: (
                    syncing: BeaconAPI.Operations.getSyncingStatus.Output.Ok.Body.jsonPayload,
                    fork: BeaconAPI.Operations.getStateFork.Output.Ok.Body.jsonPayload,
                    genesis: BeaconAPI.Operations.getGenesis.Output.Ok.Body.jsonPayload
                ),
                convertedValues: (
                    headSlot: Int64,
                    forkVersion: EthereumData,
                    genesisDataHash: Int
                )
            )
        ]()

        var highestHeadSlot: Int64 = 0
        var forkVersions: [EthereumData: Int] = [:]
        var genesisDataHashes: [Int: Int] = [:]
        for beaconNode in beaconNodesWithStatus {
            // Fetch headSlot
            guard let headSlotString = beaconNode.status.syncing.data?.head_slot?.value2, let headSlot = Int64(
                headSlotString,
                radix: 10
            ) else {
                continue
            }

            if headSlot > highestHeadSlot {
                highestHeadSlot = headSlot
            }

            // Fetch forkVersion
            guard let forkVersionString = beaconNode.status.fork.data?.current_version,
                  let forkVersion = try? EthereumData(ethereumValue: forkVersionString)
            else {
                continue
            }

            forkVersions[forkVersion] = (forkVersions[forkVersion] ?? 0) + 1

            // Select genesisDataHash
            guard let genesisDataHash = beaconNode.status.genesis.data?.hashValue else {
                continue
            }

            genesisDataHashes[genesisDataHash] = (genesisDataHashes[genesisDataHash] ?? 0) + 1

            beaconNodesWithStatusAndConvertedValues.append((
                beaconNode: beaconNode.beaconNode,
                status: beaconNode.status,
                convertedValues: (headSlot: headSlot, forkVersion: forkVersion, genesisDataHash: genesisDataHash)
            ))
        }

        // Select genesis information consens

        /// Exlcudes all beacon nodes or the given ones.
        func excludeAllBeaconNodes(_ excluded: [BeaconNodeConnection]? = nil) {
            // Remove all beacon nodes from valid set.
            let allBeaconNodes = (excluded ?? beaconNodeConnections.withLockedValue { $0 })

            if allBeaconNodes.isEmpty {
                return
            }

            app.logger
                .error(
                    "Some beacon nodes were deselected due to consens mismatch. This is recoverable in certain circumstances (>50% majority), but not expected. Please check and fix your beacon nodes."
                )
            app.logger.error("Excluded Beacon Nodes: \(allBeaconNodes.map(\.beaconNodeUrl))")

            excludedBeaconNodeConnections.withLockedValue {
                for node in allBeaconNodes {
                    $0[node] = true
                }
            }
        }

        guard let highestUsedGenesisHash = genesisDataHashes.sorted(by: { $0.value > $1.value }).first else {
            // We have no data. So return early.
            return []
        }

        guard highestUsedGenesisHash.value > (genesisDataHashes.reduce(0) { $0 + $1.value } / 2) else {
            // We have no consens majority (strict >50%)
            excludeAllBeaconNodes()
            return []
        }

        var genesisExcludedBeaconNodes = [BeaconNodeConnection]()
        beaconNodesWithStatusAndConvertedValues = beaconNodesWithStatusAndConvertedValues.filter {
            if $0.convertedValues.genesisDataHash == highestUsedGenesisHash.key {
                return true
            } else {
                genesisExcludedBeaconNodes.append($0.beaconNode)
                return false
            }
        }
        excludeAllBeaconNodes(genesisExcludedBeaconNodes)

        // Select head fork information consens

        guard let highestUsedHeadFork = forkVersions.sorted(by: { $0.value > $1.value }).first else {
            // We have no data. So return early.
            return []
        }

        guard highestUsedHeadFork.value > (forkVersions.reduce(0) { $0 + $1.value } / 2) else {
            // We have no consens majority (strict >50%)
            excludeAllBeaconNodes()
            return []
        }

        var forkExcludedBeaconNodes = [BeaconNodeConnection]()
        beaconNodesWithStatusAndConvertedValues = beaconNodesWithStatusAndConvertedValues.filter {
            if $0.convertedValues.forkVersion == highestUsedHeadFork.key {
                return true
            } else {
                forkExcludedBeaconNodes.append($0.beaconNode)
                return false
            }
        }
        excludeAllBeaconNodes(forkExcludedBeaconNodes)

        // The nodes in the set now are valid. Remove from excluded.

        excludedBeaconNodeConnections.withLockedValue {
            for beaconNode in beaconNodesWithStatusAndConvertedValues.map(\.beaconNode) {
                $0[beaconNode] = nil
            }
        }

        // Select nodes on the highest head slot. This is not a consens thing, so won't exclude those nodes.

        beaconNodesWithStatusAndConvertedValues = beaconNodesWithStatusAndConvertedValues.filter {
            $0.convertedValues.headSlot >= highestHeadSlot
        }

        return beaconNodesWithStatusAndConvertedValues.map(\.beaconNode)
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
