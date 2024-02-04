import Foundation

public struct BeaconAPIPayloadAttributesEvent: Codable, Hashable, Sendable {
    /// the identifier of the beacon hard fork at proposal_slot, e.g."bellatrix", "capella".
    public let version: String

    public let data: PayloadAttributesEventData

    public struct PayloadAttributesEventData: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let proposal_slot: String

        /// Bytes32 hexadecimal
        public let parent_block_root: String

        /// unsigned 64 bit integer
        public let parent_block_number: String

        /// Bytes32 hexadecimal
        public let parent_block_hash: String

        /// unsigned 64 bit integer
        public let proposer_index: String

        public let payload_attributes: PayloadAttributesEventType
    }

    public struct PayloadAttributesEventType: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let timestamp: String

        /// Bytes32 hexadecimal
        public let prev_randao: String

        /// eth1 address
        public let suggested_fee_recipient: String

        /// Bytes32 hexadecimal
        public let parent_beacon_block_root: String?

        public let withdrawals: [PayloadAttributesEventWithdrawal]?
    }

    public struct PayloadAttributesEventWithdrawal: Codable, Hashable, Sendable {
        /// unsigned 64 bit integer
        public let index: String

        /// unsigned 64 bit integer
        public let validator_index: String

        /// SSZ hexadecimal - pattern: ^0x[a-fA-F0-9]{2,}$
        public let address: String

        /// unsigned 64 bit integer
        public let amount: String
    }
}
