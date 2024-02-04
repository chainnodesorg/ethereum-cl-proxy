import Foundation

public struct BeaconAPIHeadEvent: Codable, Hashable, Sendable {
    /// unsigned 64 bit integer
    public let slot: String

    /// Bytes32 hexadecimal
    public let block: String

    /// Bytes32 hexadecimal
    public let state: String

    public let epoch_transition: Bool

    /// Bytes32 hexadecimal
    public let previous_duty_dependent_root: String

    /// Bytes32 hexadecimal
    public let current_duty_dependent_root: String

    public let execution_optimistic: Bool
}
