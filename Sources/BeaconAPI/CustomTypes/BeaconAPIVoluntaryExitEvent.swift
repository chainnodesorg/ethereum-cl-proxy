import Foundation

public struct BeaconAPIVoluntaryExitEvent: Codable, Hashable, Sendable {
    public let message: VoluntaryExitMessage

    /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
    public let signature: String

    public struct VoluntaryExitMessage: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let epoch: String

        /// unsigned 64 bit integer
        public let validator_index: String
    }
}
