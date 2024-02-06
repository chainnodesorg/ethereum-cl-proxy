import Foundation
import NIOConcurrencyHelpers

class TimeBasedEquivalenceCache {
    private let lock = NIOLock()

    private let keyExpirySeconds: Int64

    private var valueCache0Timestamp: Int64 = 0
    private var valueCache0: [Int: Bool] = [:]
    private var valueCache1Timestamp: Int64 = 0
    private var valueCache1: [Int: Bool] = [:]

    /// Initialized a self managing cache that checks for equivalence in form of hashes.
    ///
    /// This cache is not meant to give any 100% guarantees.
    /// 1) it is only as safe as the hash function used in the given Hashables. e.g.: if collissions happen, we can't
    /// detect.
    /// 2) we only guarantee (keyExpirySeconds / 2) seconds of cache persistence. It can be more (much more) depending
    /// on usage frequency.
    ///
    /// - Parameter keyExpirySeconds: The seconds of cache to keep. (divided by 2).
    public init(keyExpirySeconds: Int64) {
        assert(keyExpirySeconds > 1)
        self.keyExpirySeconds = keyExpirySeconds
    }

    /// Returns whether a given value is present in the cache or not.
    ///
    /// Lookup time complexity: O(1)
    ///
    /// - Parameter value: The value to check.
    /// - Returns: true if the value is in the cache, false if not.
    public func valueExists(_ value: any Hashable) -> Bool {
        lock.withLock {
            self.unsafeValueExists(value)
        }
    }

    private func unsafeValueExists(_ value: any Hashable) -> Bool {
        valueCache0[value.hashValue] == true || valueCache1[value.hashValue] == true
    }

    /// Adds a value to the cache.
    /// - Parameter value: The value to add.
    public func addValue(_ value: any Hashable) {
        lock.withLock {
            self.unsafeAddValue(value)
        }
    }

    private func unsafeAddValue(_ value: any Hashable) {
        let now = Int64(Date().timeIntervalSince1970)

        if valueCache0Timestamp >= valueCache1Timestamp {
            if valueCache0Timestamp + (keyExpirySeconds / 2) < now {
                // cache expired, switch to valueCache1
                valueCache1Timestamp = now
                valueCache1 = [:]

                valueCache1[value.hashValue] = true
            } else {
                // cache not expired. add to cache
                valueCache0[value.hashValue] = true
            }
        } else {
            if valueCache1Timestamp + (keyExpirySeconds / 2) < now {
                // cache expired, switch to valueCache0
                valueCache0Timestamp = now
                valueCache0 = [:]

                valueCache0[value.hashValue] = true
            } else {
                // cache not expired. add to cache
                valueCache1[value.hashValue] = true
            }
        }
    }

    /// Adds a value to the cache if it wasn't there yet.
    /// - Parameter value: The value to add.
    /// - Returns: true if added, false if not added (because already exists).
    public func addValueIfNotExists(_ value: any Hashable) -> Bool {
        lock.withLock {
            if unsafeValueExists(value) {
                return false
            }

            unsafeAddValue(value)

            return true
        }
    }
}
