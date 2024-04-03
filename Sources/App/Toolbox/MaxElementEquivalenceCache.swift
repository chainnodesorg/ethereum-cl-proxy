import Dispatch
import Foundation
import NIO
import NIOConcurrencyHelpers

class MaxElementEquivalenceCache {
    private let maxNumberOfValues: Int

    // private let cache: NSCache<NSNumber, NSString>
    private let cache: LRUCache<Int, Bool>

    /// Cache and compare - up to number of values
    /// - Parameter maxNumberOfValues: The numebr of values to keep, iterates after that.
    public init(maxNumberOfValues: Int) {
        self.maxNumberOfValues = maxNumberOfValues
        cache = .init(capacity: maxNumberOfValues)
    }

    /// Returns whether a given value is present in the cache or not.
    ///
    /// Lookup time complexity: O(1)
    ///
    /// - Parameter value: The value to check.
    /// - Returns: true if the value is in the cache, false if not.
    private func valueExists(_ value: any Hashable) -> Bool {
        cache.retrieveObject(at: value.hashValue) == true
        // cache.object(forKey: NSNumber(value: value.hashValue)) != nil
    }

    /// Adds a value to the cache.
    /// - Parameter value: The value to add.
    public func addValue(_ value: any Hashable) {
        addValueWithoutCheck(value)
    }

    private func addValueWithoutCheck(_ value: any Hashable) {
        cache.setObject(for: value.hashValue, value: true)
        // cache.setObject("true", forKey: NSNumber(value: value.hashValue))
    }

    /// Adds a value to the cache if it wasn't there yet.
    /// - Parameter value: The value to add.
    /// - Returns: true if added, false if not added (because already exists).
    public func addValueIfNotExists(_ value: any Hashable) -> Bool {
        if valueExists(value) {
            return false
        }

        addValueWithoutCheck(value)

        return true
    }
}
