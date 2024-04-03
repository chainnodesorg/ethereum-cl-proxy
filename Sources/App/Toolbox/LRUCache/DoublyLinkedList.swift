/// All credits go to
/// https://github.com/RinniSwift/Computer-Science-with-iOS/tree/main/DataStructures/LRUCache.playground

import Foundation

public protocol DLLPayload {
    associatedtype Key
    associatedtype Value

    var key: Key { get set }
    var value: Value { get set }
}

public struct DLLCachePayload<T: Hashable, U>: DLLPayload {
    public var key: T
    public var value: U

    public init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
}

/// A Node class to represent data objects in the LinkedList class
public class DLLNode<T: DLLPayload> {
    public var payload: T
    public var previous: DLLNode<T>?
    public var next: DLLNode<T>?

    public init(value: T) {
        payload = value
    }
}

/// An implementation of a generic doubly linkedList.
public class DoublyLinkedList<T: DLLPayload> {
    public var head: DLLNode<T>?
    public var tail: DLLNode<T>?
    var isEmpty: Bool {
        head == nil && tail == nil
    }

    public var count: Int = 0

    public init() {}

    public func prettyPrint() {
        var nodesPayload = [T]()
        var currNode = head
        while currNode != nil {
            if let payload = currNode?.payload {
                nodesPayload.append(payload)
            }
            currNode = currNode?.next
        }

        for payload in nodesPayload {
            print("(\(payload.key): \(payload.value))", terminator: " -> ")
        }
    }

    /// Traverses the nodes and returns the node at the given index and nil if no nodes are found in the LinkedList.
    /// The head starting at index 0.
    func node(at index: Int) -> DLLNode<T>? {
        guard !isEmpty || index == 0 else {
            return head
        }

        var node = head
        for _ in stride(from: 0, to: index, by: 1) {
            node = node?.next
        }

        return node
    }

    /// Adds a node from the value to the LinkedList.
    func add(value: T) {
        let node = DLLNode(value: value)

        guard !isEmpty else {
            head = node
            tail = node
            count += 1
            return
        }

        node.previous = tail
        tail?.next = node
        tail = node
        count += 1
    }

    /// The head starting at index 0
    /// - Returns: Discardable Bool indicating whether or not the insert was successful.
    @discardableResult
    public func insert(value: T, at index: Int) -> Bool {
        guard !isEmpty else {
            add(value: value)
            return true
        }

        guard case 0 ..< count = index else {
            return false
        }

        let newNode = DLLNode(value: value)

        var currNode = head
        for _ in stride(from: 0, to: index - 1, by: 1) {
            currNode = currNode?.next
        }

        if currNode === head {
            if head === tail {
                newNode.next = head
                head?.previous = newNode
                head = newNode
            } else {
                newNode.next = head
                head = newNode
            }

            count += 1
            return true
        }

        newNode.previous = currNode
        newNode.next = currNode?.next
        currNode?.next?.previous = newNode
        currNode?.next = newNode

        count += 1
        return true
    }

    /// The head starting at index 0
    /// - Returns: Discardable Bool indicating wether or not the insert was successful.
    @discardableResult
    public func insert(node: DLLNode<T>, at index: Int) -> Bool {
        guard !isEmpty else {
            head = node
            tail = node
            count += 1
            return true
        }

        guard case 0 ..< count = index else {
            return false
        }

        var currNode = head
        for _ in stride(from: 0, to: index - 1, by: 1) {
            currNode = currNode?.next
        }

        if currNode === head {
            if head === tail {
                node.next = head
                head?.previous = node
                head = node
            } else {
                node.next = head
                head = node
            }

            count += 1
            return true
        }

        node.previous = currNode
        node.next = currNode?.next
        currNode?.next?.previous = node
        currNode?.next = node

        count += 1
        return true
    }

    /// The head of the LinkedList starting at index 0
    /// - Returns: Discardable Bool indicating wether or not the remove was successful.
    @discardableResult
    func remove(at index: Int) -> Bool {
        guard case 0 ..< count = index else {
            return false
        }

        var currNode = head
        for _ in stride(from: 0, to: index, by: 1) {
            currNode = currNode?.next
        }

        if currNode === head {
            if head === tail {
                head = nil
                tail = nil
            } else {
                head?.next?.previous = nil
                head = head?.next
            }
            count -= 1
            return true
        }

        currNode?.previous?.next = currNode?.next
        currNode?.next?.previous = currNode?.previous

        count -= 1
        return true
    }

    /// Removes the last element from the linkedlist.
    /// - Returns: Discardable Bool indicating whether or not the removal was successful.
    @discardableResult
    public func remove() -> Bool {
        guard !isEmpty else {
            return false
        }

        if head === tail {
            head = nil
            tail = nil
            count -= 1
            return true
        }

        tail?.previous?.next = nil
        tail = tail?.previous

        count -= 1
        return true
    }

    public func moveToHead(node: DLLNode<T>) {
        guard !isEmpty else {
            return
        }

        if head === node, tail === node {
            // do nothing
        } else if head === node {
            // do nothing
        } else if tail === node {
            tail?.previous?.next = nil
            tail = tail?.previous

            let prevHead = head
            head?.next?.previous = node
            head = node
            head?.next = prevHead
        } else {
            var currNode = head
            while currNode?.next !== node, currNode !== tail {
                currNode = currNode?.next
            }

            currNode?.next = node.next
            node.next?.previous = currNode

            let prevHead = head
            head = node
            head?.next = prevHead
            prevHead?.previous = head
        }
    }
}
