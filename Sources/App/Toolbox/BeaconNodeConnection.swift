import BeaconAPI
import Foundation
import NIO
import NIOConcurrencyHelpers
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import OpenAPIURLSession
import Vapor
import Web3

class BeaconNodeConnection {
    // MARK: - Shared Properties

    private static let sharedHttpClient = HTTPClient(configuration: .init(
        connectionPool: HTTPClient.Configuration.ConnectionPool(
            idleTimeout: .seconds(60),
            concurrentHTTP1ConnectionsPerHostSoftLimit: 5000
        ),
        decompression: .enabled(limit: .ratio(100_000))
    ))

    // MARK: - General Properties

    private let jsonDecoder: JSONDecoder = .init()

    private let app: Application

    /// Stores the beacon node url of this instance
    let beaconNodeUrl: URL
    /// Stores the beacon node client for this instance
    let beaconNodeClient: BeaconAPI.Client

    /// The event types this beacon node is known to support / should try to subscribe to.
    let allowedEventTypes: [BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload]

    var eventCallback: NIOLockedValueBox<
        (
            BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
            String,
            any Codable & Hashable & Sendable
        ) -> Void
    >

    // MARK: - EVENT SUBSCRIPTION Properties

    /// Stores the currently handled event subscription type during the setup phase
    private let currentlyScheduledEventSubscriptionType: NIOLockedValueBox<
        BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload?
    > = .init(nil)
    /// Stores the subscriptions that returned a 200 OK at least once.
    private let currentlySubscribedEventSubscriptionTypes: NIOLockedValueBox<[
        BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload
    ]> = .init([])

    private enum EventSubscriptionFailureReason: String {
        case server
        case client
    }

    /// Stores the event subscription types that failed to receive a 200 OK and their reasons.
    /// According to specific logic, those will be retried or not.
    private let currentlyFailedEventSubscriptionTypes: NIOLockedValueBox<[
        (
            type: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
            reason: EventSubscriptionFailureReason
        )
    ]> = .init([])

    /// Stores exponential backoff times for events that couldn't be subscribed successfully because of client errors
    /// (4xx http etc.)
    private let clientFailureEventSubscriptionExponentialBackoff = ExponentialBackoffManager<
        BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload
    >(startBackoffTimeAmount: .seconds(5), maxBackoffTimeAmount: .minutes(5))

    /// Stores exponential backoff times for events that couldn't be subscribed successfully because of server errors
    /// (5xx http etc.)
    private let serverFailureEventSubscriptionExponentialBackoff = ExponentialBackoffManager<
        BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload
    >(startBackoffTimeAmount: .seconds(5), maxBackoffTimeAmount: .minutes(1))

    // MARK: - HEALTH CHECK Properties

    private let healtcheckInterval = TimeAmount.seconds(12)

    private let currentSyncHealthCheckResponse = NIOLockedValueBox<
        (response: BeaconAPI.Operations.getSyncingStatus.Output.Ok.Body.jsonPayload, time: Date)?
    >(nil)

    private let currentForkHealthCheckResponse = NIOLockedValueBox<
        (response: BeaconAPI.Operations.getStateFork.Output.Ok.Body.jsonPayload, time: Date)?
    >(nil)

    private let currentGenesisHealthCheckResponse = NIOLockedValueBox<
        (response: BeaconAPI.Operations.getGenesis.Output.Ok.Body.jsonPayload, time: Date)?
    >(nil)

    // MARK: - Initialization

    init(
        app: Application,
        beaconNodeUrl: URL,
        eventCallback: @escaping (
            BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
            String,
            any Codable & Hashable & Sendable
        ) -> Void,
        allowedEventTypes: [BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload] = [
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
        ],
        httpClient: HTTPClient = BeaconNodeConnection.sharedHttpClient
    ) {
        self.app = app

        self.beaconNodeUrl = beaconNodeUrl
        beaconNodeClient = BeaconAPI.Client(
            serverURL: beaconNodeUrl,
            transport: AsyncHTTPClientTransport(configuration: .init(client: httpClient, timeout: .seconds(60)))
        )

        self.allowedEventTypes = allowedEventTypes

        self.eventCallback = .init(eventCallback)

        // Subscribe to events for this beacon node.
        initialSubscribeToNextEvent()

        // Run health checks
        syncHealthCheck()
    }

    // MARK: - Event Subscription

    private func handleEvent(event: ServerSentEvent) {
        // We don't want to deliver events to upstream if we consider ourselves to be unhealthy.
        if !isHealthy(acceptableAge: .seconds(60)) {
            return
        }

        guard let eventString = event.event else {
            app.logger.debug("Received SSE without an event type - Beacon Node: \(beaconNodeUrl.absoluteString)")
            return
        }
        guard let eventType = BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload(rawValue: eventString)
        else {
            app.logger
                .warning("Skipping unknown event type \(eventString) - Beacon Node: \(beaconNodeUrl.absoluteString)")
            return
        }

        guard let eventDataString = event.data, let eventDataData = eventDataString.data(using: .utf8) else {
            app.logger.debug("Received SSE without event data - Beacon Node: \(beaconNodeUrl.absoluteString)")
            return
        }
        guard let eventData = try? jsonDecoder.decode(eventType.payloadType(), from: eventDataData) else {
            app.logger
                .warning(
                    "Could not decode SSE event data for type \(eventString) - Beacon Node: \(beaconNodeUrl.absoluteString)"
                )
            return
        }

        if let _ = eventData as? BeaconAPI.BeaconAPIHeadEvent, eventType == .head {
            // Schedule and register new head request to bump this connection before emitting the event.
            // This is for further requests to go to the right connections as health checks happen only every n seconds.
            app.eventLoopGroup.next().makeFutureWithTask {
                let syncStatus = try await self.beaconNodeClient.getSyncingStatus()
                let syncStatusJson = try syncStatus.ok.body.json

                self.currentSyncHealthCheckResponse.withLockedValue { $0 = (response: syncStatusJson, time: Date()) }

                // Now contact upstream.
                self.eventCallback.withLockedValue { $0(eventType, eventDataString, eventData) }
            }.whenFailure { _ in
                self.app.logger
                    .error("Could not fetch syncing status after head event - Beacon Node: \(self.beaconNodeUrl)")
            }
        } else {
            // Just emit event immediately to upstream.
            eventCallback.withLockedValue { $0(eventType, eventDataString, eventData) }
        }
    }

    /// Warn: This function is not meant to be used by multiple threads. Call it once only on startup.
    private func initialSubscribeToNextEvent() {
        let nextEventIndex: Int =
            if let currentlyScheduledEventSubscriptionType = currentlyScheduledEventSubscriptionType
                .withLockedValue({ $0 })
            {
                (allowedEventTypes.firstIndex(where: { $0 == currentlyScheduledEventSubscriptionType }) ?? -1) + 1
            } else {
                0
            }

        guard allowedEventTypes.count > nextEventIndex else {
            logEventSubscriptionStatus()

            return
        }

        let nextEvent = allowedEventTypes[nextEventIndex]
        currentlyScheduledEventSubscriptionType.withLockedValue { $0 = nextEvent }

        // The actual subscription
        _ = subscribeToEvent(event: nextEvent).always { _ in
            // Schedule the next subscription immediately.
            self.initialSubscribeToNextEvent()
        }
    }

    private enum SubscribeToEventError: Swift.Error {
        case server
        case client
    }

    private func subscribeToEvent(
        event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload
    ) -> EventLoopFuture<Void> {
        app.eventLoopGroup.next().makeFutureWithTask {
            let events = try await self.beaconNodeClient.eventstream(query: .init(topics: [
                event,
            ]), headers: .init(accept: [.init(contentType: .text_event_hyphen_stream)]))

            switch events {
            case .badRequest:
                throw SubscribeToEventError.client
            case .internalServerError:
                throw SubscribeToEventError.server
            default:
                break
            }

            let stream = try events.ok.body.text_event_hyphen_stream.asDecodedServerSentEvents()

            // At this point, we are sure that the event subscription *connection* has been successful.
            self.registerEventSubscriptionSuccess(event: event)

            _ = self.app.eventLoopGroup.next().makeFutureWithTask {
                for try await sse in stream {
                    self.handleEvent(event: sse)
                }
            }.always { result in
                switch result {
                case .success(()):
                    self.app.logger
                        .error(
                            "Beacon node event stream \(event) terminated with success, this is an error - \(self.beaconNodeUrl.absoluteString)"
                        )
                    self.app.logger
                        .info("Scheduling event subscription retry for \(event) - \(self.beaconNodeUrl.absoluteString)")

                case let .failure(error):
                    self.app.logger
                        .error(
                            "Beacon node event stream \(event) terminated with an error - \(self.beaconNodeUrl.absoluteString)"
                        )
                    self.app.logger.error("\(error)")
                    self.app.logger
                        .info("Scheduling event subscription retry for \(event) - \(self.beaconNodeUrl.absoluteString)")
                }

                // This error is not expected. We treat it as a server error to let it get scheduled again.
                self.registerEventSubscriptionFailure(event: event, reason: .server)
            }
        }.flatMapErrorThrowing { error in
            self.app.logger
                .error(
                    "Beacon node event stream \(event) could not connect - \(self.beaconNodeUrl.absoluteString)"
                )
            self.app.logger.error("\(error)")
            self.app.logger.info("Scheduling event subscription retry for \(event).")

            let errorReason: EventSubscriptionFailureReason = switch error {
            case SubscribeToEventError.client:
                .client
            default:
                .server
            }

            // Scheduler will try again.
            self.registerEventSubscriptionFailure(event: event, reason: errorReason)

            throw error
        }
    }

    private let lastLoggedSuccessfulEvents = NIOLockedValueBox<
        [BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload]
    >([])
    private let lastLoggedFailedEvents = NIOLockedValueBox<
        [BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload]
    >([])
    private let lastLoggedEventsTime = NIOLockedValueBox<Date>(Date())
    private func logEventSubscriptionStatus() {
        let events = currentlySubscribedEventSubscriptionTypes.withLockedValue { $0 }
        let failedEvents = currentlyFailedEventSubscriptionTypes.withLockedValue { $0 }

        // We always log if something new happens, otherwise max every 20 seconds.
        let now = Date()
        if events == lastLoggedSuccessfulEvents.withLockedValue({ $0 }),
           failedEvents.map(\.type) == lastLoggedFailedEvents.withLockedValue({ $0 })
        {
            if lastLoggedEventsTime.withLockedValue({ now.timeIntervalSince1970 - $0.timeIntervalSince1970 < 20 }) {
                return
            }
        }

        lastLoggedEventsTime.withLockedValue { $0 = now }
        lastLoggedSuccessfulEvents.withLockedValue { $0 = events }
        lastLoggedFailedEvents.withLockedValue { $0 = failedEvents.map(\.type) }

        app.logger.info(
            "Beacon Node subscribed to events \(events.map(\.rawValue)) - \(beaconNodeUrl.absoluteString)"
        )

        if failedEvents.count > 0 {
            app.logger.warning(
                "Beacon Node subscription failed for events \(failedEvents.map { "\($0.type.rawValue) (\($0.reason.rawValue) error)" }) - \(beaconNodeUrl.absoluteString)"
            )
        }
    }

    private func registerEventSubscriptionSuccess(
        event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload
    ) {
        // Set as success
        currentlySubscribedEventSubscriptionTypes.withLockedValue {
            $0.append(event)
        }

        // Delete from failed event subscriptions, if present
        currentlyFailedEventSubscriptionTypes.withLockedValue {
            $0.removeAll(where: {
                $0.type == event
            })
        }

        // Reset error backoffs if any
        clientFailureEventSubscriptionExponentialBackoff.resetBackoff(element: event)
        serverFailureEventSubscriptionExponentialBackoff.resetBackoff(element: event)
    }

    private func registerEventSubscriptionFailure(
        event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        reason: EventSubscriptionFailureReason
    ) {
        // Set as failure
        currentlyFailedEventSubscriptionTypes.withLockedValue {
            $0.append((type: event, reason: reason))
        }

        // Schedule retry
        scheduleEventSubscriptionFailureRetry(event: event, reason: reason)
    }

    private func scheduleEventSubscriptionFailureRetry(
        event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        reason: EventSubscriptionFailureReason
    ) {
        let backoff = switch reason {
        case .client:
            clientFailureEventSubscriptionExponentialBackoff.backoff(element: event)
        case .server:
            serverFailureEventSubscriptionExponentialBackoff.backoff(element: event)
        }

        app.eventLoopGroup.next().scheduleTask(in: backoff) {
            self.subscribeToEvent(event: event).always { _ in
                self.logEventSubscriptionStatus()
            }
        }
    }

    // MARK: - Health Check

    public func isHealthy(acceptableAge: TimeAmount) -> Bool {
        guard let syncingAge = currentSyncHealthCheckResponse.withLockedValue({ $0?.time }),
              let forkAge = currentForkHealthCheckResponse.withLockedValue({ $0?.time }),
              let genesisAge = currentGenesisHealthCheckResponse.withLockedValue({ $0?.time })
        else {
            return false
        }

        let now = Date()
        let nsInS: Double = 1_000_000_000

        guard Int64(now.timeIntervalSince(syncingAge) * nsInS) <= acceptableAge.nanoseconds else {
            return false
        }
        guard Int64(now.timeIntervalSince(forkAge) * nsInS) <= acceptableAge.nanoseconds else {
            return false
        }
        guard Int64(now.timeIntervalSince(genesisAge) * nsInS) <= acceptableAge.nanoseconds else {
            return false
        }

        return true
    }

    public func chainStatus() -> (
        syncing: BeaconAPI.Operations.getSyncingStatus.Output.Ok.Body.jsonPayload?,
        fork: BeaconAPI.Operations.getStateFork.Output.Ok.Body.jsonPayload?,
        genesis: BeaconAPI.Operations.getGenesis.Output.Ok.Body.jsonPayload?
    ) {
        let syncing = currentSyncHealthCheckResponse.withLockedValue { $0?.response }
        let fork = currentForkHealthCheckResponse.withLockedValue { $0?.response }
        let genesis = currentGenesisHealthCheckResponse.withLockedValue { $0?.response }

        return (syncing: syncing, fork: fork, genesis: genesis)
    }

    private func syncHealthCheck() {
        _ = app.eventLoopGroup.makeFutureWithTask {
            let now = Date()

            let syncingStatus = try await self.beaconNodeClient.getSyncingStatus().ok.body.json
            let forkStatus = try await self.beaconNodeClient.getStateFork(path: .init(state_id: "head")).ok.body.json
            let genesisStatus = try await self.beaconNodeClient.getGenesis().ok.body.json

            self.currentSyncHealthCheckResponse.withLockedValue { $0 = (response: syncingStatus, time: now) }
            self.currentForkHealthCheckResponse.withLockedValue { $0 = (response: forkStatus, time: now) }
            self.currentGenesisHealthCheckResponse.withLockedValue { $0 = (response: genesisStatus, time: now) }
        }.always { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                self.currentSyncHealthCheckResponse.withLockedValue { $0 = nil }
                self.currentForkHealthCheckResponse.withLockedValue { $0 = nil }
                self.currentGenesisHealthCheckResponse.withLockedValue { $0 = nil }
            }

            // Always schedule the next health check after the interval
            self.app.eventLoopGroup.next().scheduleTask(in: self.healtcheckInterval) {
                self.syncHealthCheck()
            }
        }
    }

    private let lastLoggedHealthCheckFailureTime = NIOLockedValueBox<Date>(Date())
    private func logHealthCheckFailure(error: Error) {
        let now = Date()
        guard now.timeIntervalSince1970 - lastLoggedHealthCheckFailureTime.withLockedValue({ $0 })
            .timeIntervalSince1970 >= 60
        else {
            return
        }

        app.logger.error("Health check failed for beacon node - \(beaconNodeUrl)")
        app.logger.error("\(error)")
    }
}

extension BeaconNodeConnection: Equatable, Hashable {
    static func == (_ lhs: BeaconNodeConnection, _ rhs: BeaconNodeConnection) -> Bool {
        lhs.beaconNodeUrl == rhs.beaconNodeUrl && lhs.allowedEventTypes == rhs.allowedEventTypes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(beaconNodeUrl)
        hasher.combine(allowedEventTypes)
    }
}

// MARK: - Event Type to JSON data types

extension BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload {
    private struct EmptyJson: Codable, Hashable, Sendable {}

    typealias PayloadType = Codable & Hashable & Sendable

    func payloadType() -> any PayloadType.Type {
        switch self {
        case .head:
            BeaconAPI.BeaconAPIHeadEvent.self
        case .block:
            BeaconAPI.BeaconAPIBlockEvent.self
        case .attestation:
            BeaconAPI.BeaconAPIAttestationEvent.self
        case .voluntary_exit:
            BeaconAPI.BeaconAPIVoluntaryExitEvent.self
        case .finalized_checkpoint:
            BeaconAPI.BeaconAPIFinalizedCheckpointEvent.self
        case .chain_reorg:
            BeaconAPI.BeaconAPIChainReorgEvent.self
        case .contribution_and_proof:
            BeaconAPI.BeaconAPIContributionAndProof.self
        case .payload_attributes:
            BeaconAPI.BeaconAPIPayloadAttributesEvent.self
        default:
            EmptyJson.self
        }
    }
}
