import Foundation

public struct BeaconAPIAttestationEvent: Codable, Hashable, Sendable {
    /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
    public let aggregation_bits: String

    /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
    public let signature: String

    public let data: AttestationData

    public struct AttestationData: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let slot: String

        /// unsigned 64 bit integer
        public let index: String

        /// Bytes32 hexadecimal
        public let beacon_block_root: String

        public let source: AttestationCheckpoint

        public let target: AttestationCheckpoint
    }

    public struct AttestationCheckpoint: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let epoch: String

        /// Bytes32 hexadecimal
        public let root: String
    }
}
