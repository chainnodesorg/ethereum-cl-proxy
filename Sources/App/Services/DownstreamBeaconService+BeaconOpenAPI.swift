import BeaconAPI
import Foundation
import NIOConcurrencyHelpers
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

extension DownstreamBeaconService: APIProtocol {
    // MARK: - Stream Cancellation

    func cancelUpstreamEventStream(_ body: OpenAPIRuntime.HTTPBody) {
        runningUpstreamBeaconNodeEventStreams.withLockedValue { $0[body] }?.cancelContinuation()
    }

    // MARK: - OpenAPI APIProtocol implementation

    enum OpenAPIError: Swift.Error {
        case notImplemented
    }

    // NEW IN 2.5.0

    func postStateValidators(
        _ input: BeaconAPI.Operations.postStateValidators.Input
    ) async throws -> BeaconAPI.Operations.postStateValidators.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func postStateValidatorBalances(
        _ input: BeaconAPI.Operations.postStateValidatorBalances.Input
    ) async throws -> BeaconAPI.Operations.postStateValidatorBalances.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    // END NEW IN 2.5.0

    func getStateValidator(
        _ input: BeaconAPI.Operations.getStateValidator.Input
    ) async throws -> BeaconAPI.Operations.getStateValidator.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getStateValidatorBalances(
        _ input: BeaconAPI.Operations.getStateValidatorBalances.Input
    ) async throws -> BeaconAPI.Operations.getStateValidatorBalances.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getEpochCommittees(
        _ input: BeaconAPI.Operations.getEpochCommittees.Input
    ) async throws -> BeaconAPI.Operations
        .getEpochCommittees.Output
    {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getEpochSyncCommittees(
        _ input: BeaconAPI.Operations.getEpochSyncCommittees.Input
    ) async throws -> BeaconAPI.Operations.getEpochSyncCommittees.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getStateRandao(
        _ input: BeaconAPI.Operations.getStateRandao.Input
    ) async throws -> BeaconAPI.Operations.getStateRandao.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlockHeaders(
        _ input: BeaconAPI.Operations.getBlockHeaders.Input
    ) async throws -> BeaconAPI.Operations.getBlockHeaders.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlockHeader(
        _ input: BeaconAPI.Operations.getBlockHeader.Input
    ) async throws -> BeaconAPI.Operations.getBlockHeader.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func publishBlindedBlock(
        _ input: BeaconAPI.Operations.publishBlindedBlock.Input
    ) async throws -> BeaconAPI.Operations.publishBlindedBlock.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.publishBlindedBlock(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func publishBlindedBlockV2(
        _ input: BeaconAPI.Operations.publishBlindedBlockV2.Input
    ) async throws -> BeaconAPI
        .Operations.publishBlindedBlockV2.Output
    {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.publishBlindedBlockV2(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func publishBlock(
        _ input: BeaconAPI.Operations.publishBlock.Input
    ) async throws -> BeaconAPI.Operations.publishBlock.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.publishBlock(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func publishBlockV2(
        _ input: BeaconAPI.Operations.publishBlockV2.Input
    ) async throws -> BeaconAPI.Operations.publishBlockV2.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.publishBlockV2(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func getBlockV2(
        _ input: BeaconAPI.Operations.getBlockV2.Input
    ) async throws -> BeaconAPI.Operations.getBlockV2.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlockRoot(
        _ input: BeaconAPI.Operations.getBlockRoot.Input
    ) async throws -> BeaconAPI.Operations.getBlockRoot.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlockAttestations(
        _ input: BeaconAPI.Operations.getBlockAttestations.Input
    ) async throws -> BeaconAPI.Operations.getBlockAttestations.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlobSidecars(
        _ input: BeaconAPI.Operations.getBlobSidecars.Input
    ) async throws -> BeaconAPI.Operations.getBlobSidecars.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getSyncCommitteeRewards(
        _ input: BeaconAPI.Operations.getSyncCommitteeRewards.Input
    ) async throws -> BeaconAPI.Operations.getSyncCommitteeRewards.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getDepositSnapshot(
        _ input: BeaconAPI.Operations.getDepositSnapshot.Input
    ) async throws -> BeaconAPI.Operations.getDepositSnapshot.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlockRewards(
        _ input: BeaconAPI.Operations.getBlockRewards.Input
    ) async throws -> BeaconAPI.Operations.getBlockRewards.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getAttestationsRewards(
        _ input: BeaconAPI.Operations.getAttestationsRewards.Input
    ) async throws -> BeaconAPI.Operations.getAttestationsRewards.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getBlindedBlock(
        _ input: BeaconAPI.Operations.getBlindedBlock.Input
    ) async throws -> BeaconAPI.Operations.getBlindedBlock.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getLightClientBootstrap(
        _ input: BeaconAPI.Operations.getLightClientBootstrap.Input
    ) async throws -> BeaconAPI.Operations.getLightClientBootstrap.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getLightClientUpdatesByRange(
        _ input: BeaconAPI.Operations.getLightClientUpdatesByRange.Input
    ) async throws -> BeaconAPI.Operations.getLightClientUpdatesByRange.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getLightClientFinalityUpdate(
        _ input: BeaconAPI.Operations.getLightClientFinalityUpdate.Input
    ) async throws -> BeaconAPI.Operations.getLightClientFinalityUpdate.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getLightClientOptimisticUpdate(
        _ input: BeaconAPI.Operations.getLightClientOptimisticUpdate.Input
    ) async throws -> BeaconAPI.Operations.getLightClientOptimisticUpdate.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getPoolAttestations(
        _ input: BeaconAPI.Operations.getPoolAttestations.Input
    ) async throws -> BeaconAPI.Operations.getPoolAttestations.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitPoolAttestations(
        _ input: BeaconAPI.Operations.submitPoolAttestations.Input
    ) async throws -> BeaconAPI.Operations.submitPoolAttestations.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.submitPoolAttestations(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func getPoolAttesterSlashings(
        _ input: BeaconAPI.Operations.getPoolAttesterSlashings.Input
    ) async throws -> BeaconAPI.Operations.getPoolAttesterSlashings.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitPoolAttesterSlashings(
        _ input: BeaconAPI.Operations.submitPoolAttesterSlashings.Input
    ) async throws -> BeaconAPI.Operations.submitPoolAttesterSlashings.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getPoolProposerSlashings(
        _ input: BeaconAPI.Operations.getPoolProposerSlashings.Input
    ) async throws -> BeaconAPI.Operations.getPoolProposerSlashings.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitPoolProposerSlashings(
        _ input: BeaconAPI.Operations.submitPoolProposerSlashings.Input
    ) async throws -> BeaconAPI.Operations.submitPoolProposerSlashings.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitPoolSyncCommitteeSignatures(
        _ input: BeaconAPI.Operations.submitPoolSyncCommitteeSignatures.Input
    ) async throws -> BeaconAPI.Operations.submitPoolSyncCommitteeSignatures.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.submitPoolSyncCommitteeSignatures(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func getPoolVoluntaryExits(
        _ input: BeaconAPI.Operations.getPoolVoluntaryExits.Input
    ) async throws -> BeaconAPI.Operations.getPoolVoluntaryExits.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitPoolVoluntaryExit(
        _ input: BeaconAPI.Operations.submitPoolVoluntaryExit.Input
    ) async throws -> BeaconAPI.Operations.submitPoolVoluntaryExit.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getPoolBLSToExecutionChanges(
        _ input: BeaconAPI.Operations.getPoolBLSToExecutionChanges.Input
    ) async throws -> BeaconAPI.Operations.getPoolBLSToExecutionChanges.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitPoolBLSToExecutionChange(
        _ input: BeaconAPI.Operations.submitPoolBLSToExecutionChange.Input
    ) async throws -> BeaconAPI.Operations.submitPoolBLSToExecutionChange.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getNextWithdrawals(
        _ input: BeaconAPI.Operations.getNextWithdrawals.Input
    ) async throws -> BeaconAPI.Operations.getNextWithdrawals.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getStateV2(
        _ input: BeaconAPI.Operations.getStateV2.Input
    ) async throws -> BeaconAPI.Operations.getStateV2.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getDebugChainHeadsV2(
        _ input: BeaconAPI.Operations.getDebugChainHeadsV2.Input
    ) async throws -> BeaconAPI.Operations.getDebugChainHeadsV2.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getDebugForkChoice(
        _ input: BeaconAPI.Operations.getDebugForkChoice.Input
    ) async throws -> BeaconAPI.Operations.getDebugForkChoice.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getNetworkIdentity(
        _ input: BeaconAPI.Operations.getNetworkIdentity.Input
    ) async throws -> BeaconAPI.Operations.getNetworkIdentity.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getPeers(
        _ input: BeaconAPI.Operations.getPeers.Input
    ) async throws -> BeaconAPI.Operations.getPeers.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getPeer(_ input: BeaconAPI.Operations.getPeer.Input) async throws -> BeaconAPI.Operations.getPeer.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getPeerCount(
        _ input: BeaconAPI.Operations.getPeerCount.Input
    ) async throws -> BeaconAPI.Operations.getPeerCount.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getNodeVersion(
        _ input: BeaconAPI.Operations.getNodeVersion.Input
    ) async throws -> BeaconAPI.Operations.getNodeVersion.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getSyncingStatus(
        _ input: BeaconAPI.Operations.getSyncingStatus.Input
    ) async throws -> BeaconAPI.Operations.getSyncingStatus.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getSyncingStatus(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getHealth(
        _ input: BeaconAPI.Operations.getHealth.Input
    ) async throws -> BeaconAPI.Operations.getHealth.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getForkSchedule(
        _ input: BeaconAPI.Operations.getForkSchedule.Input
    ) async throws -> BeaconAPI.Operations.getForkSchedule.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getSpec(_ input: BeaconAPI.Operations.getSpec.Input) async throws -> BeaconAPI.Operations.getSpec.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getSpec(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getDepositContract(
        _ input: BeaconAPI.Operations.getDepositContract.Input
    ) async throws -> BeaconAPI.Operations.getDepositContract.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getDepositContract(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getAttesterDuties(
        _ input: BeaconAPI.Operations.getAttesterDuties.Input
    ) async throws -> BeaconAPI.Operations.getAttesterDuties.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getAttesterDuties(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getProposerDuties(
        _ input: BeaconAPI.Operations.getProposerDuties.Input
    ) async throws -> BeaconAPI.Operations.getProposerDuties.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getProposerDuties(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getSyncCommitteeDuties(
        _ input: BeaconAPI.Operations.getSyncCommitteeDuties.Input
    ) async throws -> BeaconAPI.Operations.getSyncCommitteeDuties.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getSyncCommitteeDuties(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func produceBlockV2(
        _ input: BeaconAPI.Operations.produceBlockV2.Input
    ) async throws -> BeaconAPI.Operations.produceBlockV2.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.produceBlockV2(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(headers: chosenResponse.0.headers, body: chosenResponse.0.body))
    }

    func produceBlockV3(
        _ input: BeaconAPI.Operations.produceBlockV3.Input
    ) async throws -> BeaconAPI.Operations.produceBlockV3.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.produceBlockV3(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(headers: chosenResponse.0.headers, body: chosenResponse.0.body))
    }

    func produceBlindedBlock(
        _ input: BeaconAPI.Operations.produceBlindedBlock.Input
    ) async throws -> BeaconAPI.Operations.produceBlindedBlock.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.produceBlindedBlock(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(headers: chosenResponse.0.headers, body: chosenResponse.0.body))
    }

    func produceAttestationData(
        _ input: BeaconAPI.Operations.produceAttestationData.Input
    ) async throws -> BeaconAPI.Operations.produceAttestationData.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.produceAttestationData(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getAggregatedAttestation(
        _ input: BeaconAPI.Operations.getAggregatedAttestation.Input
    ) async throws -> BeaconAPI.Operations.getAggregatedAttestation.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getAggregatedAttestation(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func publishAggregateAndProofs(
        _ input: BeaconAPI.Operations.publishAggregateAndProofs.Input
    ) async throws -> BeaconAPI.Operations.publishAggregateAndProofs.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.publishAggregateAndProofs(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func prepareBeaconCommitteeSubnet(
        _ input: BeaconAPI.Operations.prepareBeaconCommitteeSubnet.Input
    ) async throws -> BeaconAPI.Operations.prepareBeaconCommitteeSubnet.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.prepareBeaconCommitteeSubnet(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func prepareSyncCommitteeSubnets(
        _ input: BeaconAPI.Operations.prepareSyncCommitteeSubnets.Input
    ) async throws -> BeaconAPI.Operations.prepareSyncCommitteeSubnets.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.prepareSyncCommitteeSubnets(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func submitBeaconCommitteeSelections(
        _ input: BeaconAPI.Operations.submitBeaconCommitteeSelections.Input
    ) async throws -> BeaconAPI.Operations.submitBeaconCommitteeSelections.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.submitBeaconCommitteeSelections(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func produceSyncCommitteeContribution(
        _ input: BeaconAPI.Operations.produceSyncCommitteeContribution.Input
    ) async throws -> BeaconAPI.Operations.produceSyncCommitteeContribution.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.produceSyncCommitteeContribution(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func submitSyncCommitteeSelections(
        _ input: BeaconAPI.Operations.submitSyncCommitteeSelections.Input
    ) async throws -> BeaconAPI.Operations.submitSyncCommitteeSelections.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.submitSyncCommitteeSelections(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func publishContributionAndProofs(
        _ input: BeaconAPI.Operations.publishContributionAndProofs.Input
    ) async throws -> BeaconAPI.Operations.publishContributionAndProofs.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.publishContributionAndProofs(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func prepareBeaconProposer(
        _ input: BeaconAPI.Operations.prepareBeaconProposer.Input
    ) async throws -> BeaconAPI.Operations.prepareBeaconProposer.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.prepareBeaconProposer(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func registerValidator(
        _ input: BeaconAPI.Operations.registerValidator.Input
    ) async throws -> BeaconAPI.Operations.registerValidator.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.registerValidator(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(chosenResponse.0)
    }

    func getLiveness(
        _ input: BeaconAPI.Operations.getLiveness.Input
    ) async throws -> BeaconAPI.Operations.getLiveness.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getLiveness(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func eventstream(
        _ input: BeaconAPI.Operations.eventstream.Input
    ) async throws -> BeaconAPI.Operations.eventstream.Output {
        let subscriptionTypes = input.query.topics

        let subscriptionId = NIOLockedValueBox<String>("")

        let stream = BeaconNodeEventStream(unsubscribeCallback: {
            self.unsubscribe(subscriptionId: subscriptionId.withLockedValue { $0 })
        })

        subscriptionId.withLockedValue {
            $0 = subscribe(eventTypes: subscriptionTypes, callback: stream.eventCallback(_:_:))
        }

        // Now stream the result

        let chosenContentType = input.headers.accept.sortedByQuality()
            .first ?? .init(contentType: .text_event_hyphen_stream)

        let responseBody: BeaconAPI.Operations.eventstream.Output.Ok.Body
        switch chosenContentType.contentType {
        default:
            let httpBody = OpenAPIRuntime.HTTPBody(
                stream.stream.map { event in
                    ServerSentEvent(
                        id: UUID().uuidString,
                        event: event.event.rawValue,
                        data: event.data,
                        retry: 10000
                    )
                }.asEncodedServerSentEvents(),
                length: .unknown,
                iterationBehavior: .single
            )
            // Save for cancellation
            runningUpstreamBeaconNodeEventStreams.withLockedValue { $0[httpBody] = stream }

            // Set response body
            responseBody = .text_event_hyphen_stream(
                httpBody
            )
        }

        return .ok(.init(body: responseBody))
    }

    func getStateValidators(
        _ input: BeaconAPI.Operations.getStateValidators.Input
    ) async throws -> BeaconAPI.Operations.getStateValidators.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getStateValidators(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getStateFinalityCheckpoints(
        _ input: BeaconAPI.Operations.getStateFinalityCheckpoints.Input
    ) async throws -> BeaconAPI.Operations.getStateFinalityCheckpoints.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getStateFork(
        _ input: BeaconAPI.Operations.getStateFork.Input
    ) async throws -> BeaconAPI.Operations.getStateFork.Output {
        let connections = try forceHealthyBeaconNodeConnections()

        let responses = try await WaitForResponseAndTimeout.multiple(
            connections.map { connection in
                {
                    try await connection.beaconNodeClient.getStateFork(input)
                }
            },
            timeout: Constants.FAST_REQUESTS_MAX_WAIT
        )

        let mapped = responses.compactMap { try? $0.get().ok.body.json }

        let chosenResponse = try WaitForResponseAndTimeout.consensResponses(mapped)

        return .ok(.init(body: .json(chosenResponse.0)))
    }

    func getStateRoot(
        _ input: BeaconAPI.Operations.getStateRoot.Input
    ) async throws -> BeaconAPI.Operations.getStateRoot.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getGenesis(
        _: BeaconAPI.Operations.getGenesis.Input
    ) async throws -> BeaconAPI.Operations.getGenesis.Output {
        let connections = try forceHealthyBeaconNodeConnections()
        let chainStatusArray = connections.compactMap {
            $0.chainStatus().genesis
        }
        if chainStatusArray.count < 1 {
            throw Error.noHealthyBeaconNodeConnections
        }

        return .ok(.init(body: .json(chainStatusArray[0])))
    }
}

final class BeaconNodeEventStream: Sendable {
    struct BeaconNodeEvent {
        let event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload
        let data: String
    }

    typealias StreamType = AsyncStream<BeaconNodeEvent>

    private let lock: NIOLock = .init()

    private let unsubscribeCallback: @Sendable () -> Void

    let stream: StreamType
    private let continuation: StreamType.Continuation

    init(unsubscribeCallback: @escaping () -> Void) {
        self.unsubscribeCallback = unsubscribeCallback

        let (stream, continuation) = StreamType.makeStream()
        self.stream = stream
        self.continuation = continuation

        continuation.onTermination = { termination in
            switch termination {
            case .cancelled, .finished:
                unsubscribeCallback()
            @unknown default:
                unsubscribeCallback()
            }
        }
    }

    func eventCallback(
        _ event: BeaconAPI.Operations.eventstream.Input.Query.topicsPayloadPayload,
        _ data: String
    ) {
        _ = lock.withLock {
            continuation.yield(.init(event: event, data: data))
        }
    }

    func cancelContinuation() {
        lock.withLock {
            continuation.finish()
        }
    }
}
