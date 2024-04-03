/// All credits go to
/// https://github.com/RinniSwift/Computer-Science-with-iOS/tree/main/DataStructures/LRUCache.playground

import Foundation
import NIOConcurrencyHelpers

class LRUCache<T: Hashable, U> {
    private let lock: NIOLock = .init()

    /// Total capacity of the LRU cache.
    private let capacity: Int
    /// LinkedList will store elements that are most accessed at the head and least accessed at the tail.
    private var linkedList = DoublyLinkedList<DLLCachePayload<T, U>>()
    /// Dictionary that will store the element, T, at the specified key.
    private var dictionary = [T: DLLNode<DLLCachePayload<T, U>>]()

    /// LRUCache requires a capacity which must be greater than 0
    required init(capacity: Int) {
        self.capacity = capacity
    }

    /// Sets the specified value at the specified key in the cache.
    func setObject(for key: T, value: U) {
        let element = DLLCachePayload(key: key, value: value)
        let node = DLLNode(value: element)

        lock.withLock {
            if let existingNode = dictionary[key] {
                // move the existing node to head
                linkedList.moveToHead(node: existingNode)
                linkedList.head?.payload.value = value
                dictionary[key] = node
            } else {
                if linkedList.count >= capacity {
                    if let leastAccessedKey = linkedList.tail?.payload.key {
                        dictionary[leastAccessedKey] = nil
                    }
                    linkedList.remove()
                }

                linkedList.insert(node: node, at: 0)
                dictionary[key] = node
            }
        }
    }

    /// Returns the element at the specified key. Nil if it doesn't exist.
    func retrieveObject(at key: T) -> U? {
        let existingNode: U? = lock.withLock {
            if let node = dictionary[key] {
                linkedList.moveToHead(node: node)
                return node.payload.value
            }

            return nil
        }

        return existingNode
    }
}
