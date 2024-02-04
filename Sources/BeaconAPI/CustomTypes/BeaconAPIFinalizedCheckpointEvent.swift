import Foundation

public struct BeaconAPIFinalizedCheckpointEvent: Codable, Hashable, Sendable {
    /// Bytes32 hexadecimal
    public let block: String

    /// Bytes32 hexadecimal
    public let state: String

    /// unsigned 64 bit integer
    public let epoch: String

    public let execution_optimistic: Bool
}
