import BeaconAPI
import Foundation
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

class ProxyController: RouteCollection, APIProtocol {
    // MARK: - Properties

    private let jsonEncoder = JSONEncoder()

    private let app: Application

    // MARK: - Initialization

    init(app: Application) {
        self.app = app
    }

    // MARK: - Normal Vapor RouteCollection

    func boot(routes _: RoutesBuilder) throws {}

    // MARK: - OpenAPI APIProtocol implementation

    enum OpenAPIError: Error {
        case notImplemented
    }

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
        print(input)
        throw OpenAPIError.notImplemented
    }

    func publishBlindedBlockV2(
        _ input: BeaconAPI.Operations.publishBlindedBlockV2.Input
    ) async throws -> BeaconAPI
        .Operations.publishBlindedBlockV2.Output
    {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func publishBlock(
        _ input: BeaconAPI.Operations.publishBlock.Input
    ) async throws -> BeaconAPI.Operations.publishBlock.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func publishBlockV2(
        _ input: BeaconAPI.Operations.publishBlockV2.Input
    ) async throws -> BeaconAPI.Operations.publishBlockV2.Output {
        print(input)
        throw OpenAPIError.notImplemented
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
        print(input)
        throw OpenAPIError.notImplemented
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
        print(input)
        throw OpenAPIError.notImplemented
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
        print(input)
        throw OpenAPIError.notImplemented
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
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getDepositContract(
        _ input: BeaconAPI.Operations.getDepositContract.Input
    ) async throws -> BeaconAPI.Operations.getDepositContract.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getAttesterDuties(
        _ input: BeaconAPI.Operations.getAttesterDuties.Input
    ) async throws -> BeaconAPI.Operations.getAttesterDuties.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getProposerDuties(
        _ input: BeaconAPI.Operations.getProposerDuties.Input
    ) async throws -> BeaconAPI.Operations.getProposerDuties.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getSyncCommitteeDuties(
        _ input: BeaconAPI.Operations.getSyncCommitteeDuties.Input
    ) async throws -> BeaconAPI.Operations.getSyncCommitteeDuties.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func produceBlockV2(
        _ input: BeaconAPI.Operations.produceBlockV2.Input
    ) async throws -> BeaconAPI.Operations.produceBlockV2.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func produceBlockV3(
        _ input: BeaconAPI.Operations.produceBlockV3.Input
    ) async throws -> BeaconAPI.Operations.produceBlockV3.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func produceBlindedBlock(
        _ input: BeaconAPI.Operations.produceBlindedBlock.Input
    ) async throws -> BeaconAPI.Operations.produceBlindedBlock.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func produceAttestationData(
        _ input: BeaconAPI.Operations.produceAttestationData.Input
    ) async throws -> BeaconAPI.Operations.produceAttestationData.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getAggregatedAttestation(
        _ input: BeaconAPI.Operations.getAggregatedAttestation.Input
    ) async throws -> BeaconAPI.Operations.getAggregatedAttestation.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func publishAggregateAndProofs(
        _ input: BeaconAPI.Operations.publishAggregateAndProofs.Input
    ) async throws -> BeaconAPI.Operations.publishAggregateAndProofs.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func prepareBeaconCommitteeSubnet(
        _ input: BeaconAPI.Operations.prepareBeaconCommitteeSubnet.Input
    ) async throws -> BeaconAPI.Operations.prepareBeaconCommitteeSubnet.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func prepareSyncCommitteeSubnets(
        _ input: BeaconAPI.Operations.prepareSyncCommitteeSubnets.Input
    ) async throws -> BeaconAPI.Operations.prepareSyncCommitteeSubnets.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitBeaconCommitteeSelections(
        _ input: BeaconAPI.Operations.submitBeaconCommitteeSelections.Input
    ) async throws -> BeaconAPI.Operations.submitBeaconCommitteeSelections.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func produceSyncCommitteeContribution(
        _ input: BeaconAPI.Operations.produceSyncCommitteeContribution.Input
    ) async throws -> BeaconAPI.Operations.produceSyncCommitteeContribution.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func submitSyncCommitteeSelections(
        _ input: BeaconAPI.Operations.submitSyncCommitteeSelections.Input
    ) async throws -> BeaconAPI.Operations.submitSyncCommitteeSelections.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func publishContributionAndProofs(
        _ input: BeaconAPI.Operations.publishContributionAndProofs.Input
    ) async throws -> BeaconAPI.Operations.publishContributionAndProofs.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func prepareBeaconProposer(
        _ input: BeaconAPI.Operations.prepareBeaconProposer.Input
    ) async throws -> BeaconAPI.Operations.prepareBeaconProposer.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func registerValidator(
        _ input: BeaconAPI.Operations.registerValidator.Input
    ) async throws -> BeaconAPI.Operations.registerValidator.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getLiveness(
        _ input: BeaconAPI.Operations.getLiveness.Input
    ) async throws -> BeaconAPI.Operations.getLiveness.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func eventstream(
        _ input: BeaconAPI.Operations.eventstream.Input
    ) async throws -> BeaconAPI.Operations.eventstream.Output {
        try await app.downstreamBeaconService.eventstream(input)
    }

    func getStateValidators(
        _ input: BeaconAPI.Operations.getStateValidators.Input
    ) async throws -> BeaconAPI.Operations.getStateValidators.Output {
        print(input)
        throw OpenAPIError.notImplemented
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
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getStateRoot(
        _ input: BeaconAPI.Operations.getStateRoot.Input
    ) async throws -> BeaconAPI.Operations.getStateRoot.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }

    func getGenesis(
        _ input: BeaconAPI.Operations.getGenesis.Input
    ) async throws -> BeaconAPI.Operations.getGenesis.Output {
        print(input)
        throw OpenAPIError.notImplemented
    }
}
