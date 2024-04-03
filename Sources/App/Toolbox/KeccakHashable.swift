import BeaconAPI
import CryptoSwift
import Foundation
import Web3

protocol KeccakHashable {
    var keccakHashValue: [UInt8] { get }
}

extension BeaconAPI.Operations.getGenesis.Output.Ok.Body.jsonPayload.dataPayload: KeccakHashable {
    var keccakHashValue: [UInt8] {
        var combinedValues = [UInt8]()

        combinedValues.append(contentsOf: genesis_time.data(using: .utf8) ?? Data())
        combinedValues
            .append(contentsOf: (try? EthereumData(ethereumValue: genesis_validators_root))?
                .bytes ?? genesis_validators_root.bytes)
        combinedValues
            .append(contentsOf: (try? EthereumData(ethereumValue: genesis_fork_version ?? ""))?
                .bytes ?? genesis_fork_version.bytes)

        return combinedValues.sha3(.keccak256)
    }
}
