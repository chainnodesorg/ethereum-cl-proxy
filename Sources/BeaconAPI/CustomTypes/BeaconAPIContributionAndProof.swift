import Foundation

public struct BeaconAPIContributionAndProof: Codable, Hashable, Sendable {
    let message: ContributionAndProofMessage

    /// Bytes hexadecimal
    let signature: String

    public struct ContributionAndProofMessage: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let aggregator_index: String

        /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
        public let selection_proof: String

        public let contribution: SyncCommitteeContribution

        public struct SyncCommitteeContribution: Codable, Hashable, Sendable {
            /// unsigned 64 bit integer
            public let slot: String

            /// Bytes32 hexadecimal
            public let beacon_block_root: String

            /// unsigned 64 bit integer
            public let subcommittee_index: String

            /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
            public let aggregation_bits: String

            /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
            public let signature: String
        }
    }
}
