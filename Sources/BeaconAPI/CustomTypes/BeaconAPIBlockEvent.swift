import Foundation

public struct BeaconAPIBlockEvent: Codable, Hashable, Sendable {
    /// unsigned 64 bit integer
    public let slot: String

    /// Bytes32 hexadecimal
    public let block: String

    public let execution_optimistic: Bool
}
