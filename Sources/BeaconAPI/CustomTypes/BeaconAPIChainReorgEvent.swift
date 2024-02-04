import Foundation

public struct BeaconAPIChainReorgEvent: Codable, Hashable, Sendable {
    /// unsigned 64 bit integer
    public let slot: String

    /// unsigned 64 bit integer
    public let depth: String

    /// Bytes32 hexadecimal
    public let old_head_block: String

    /// Bytes32 hexadecimal
    public let new_head_block: String

    /// Bytes32 hexadecimal
    public let old_head_state: String

    /// Bytes32 hexadecimal
    public let new_head_state: String

    /// unsigned 64 bit integer
    public let epoch: String

    public let execution_optimistic: Bool
}
