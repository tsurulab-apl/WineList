//
//  LinkedList.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

public class Node<T: Equatable> {
    typealias NodeType = Node<T>
    
    /// The value contained in this node
    public let value: T
    var next: NodeType? = nil
    var previous: NodeType? = nil
    
    public init(value: T) {
        self.value = value
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        get {
            return "Node(\(value))"
        }
    }
}

//
public final class LinkedList<T: Equatable> {
    public typealias NodeType = Node<T>
    
    fileprivate var start: NodeType? {
        didSet {
            // Special case for a 1 element list
            if end == nil {
                end = start
            }
        }
    }
    
    fileprivate var end: NodeType? {
        didSet {
            // Special case for a 1 element list
            if start == nil {
                start = end
            }
        }
    }
    
    /// The number of elements in the list at any given time
    public private(set) var count: Int = 0
    
    /// Wether or not the list is empty. Returns `true` when
    /// count is 0 and `false` otherwise
    public var isEmpty: Bool {
        get {
            return count == 0
        }
    }
    
    /// Create a new LinkedList
    ///
    /// - returns: An empty LinkedList
    public init() {
        
    }
    
    /// Create a new LinkedList with a sequence
    ///
    /// - parameter: A sequence
    /// - returns: A LinkedList containing the elements of the provided sequence
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == T {
        for element in elements {
            append(value: element)
        }
    }

    /// Add an element to the front of the list.
    ///
    /// - complexity: O(1)
    /// - parameter value: The value to add
    public func append(value: T) {
        let previousEnd = end
        end = NodeType(value: value)
        
        end?.previous = previousEnd
        previousEnd?.next = end
        
        count += 1
    }
    /// Utility method to iterate over all nodes in the list invoking a block
    /// for each element and stopping if the block returns a non nil `NodeType`
    ///
    /// - complexity: O(n)
    /// - parameter block: A block to invoke for each element. Return the current node
    ///                    from this block to stop iteration
    ///
    /// - throws: Rethrows any values thrown by the block
    ///
    /// - returns: The node returned by the block if the block ever returns a node otherwise `nil`
    private func iterate(block: (_ node: NodeType, _ index: Int) throws -> NodeType?) rethrows -> NodeType? {
        var node = start
        var index = 0
        
        while node != nil {
            let result = try block(node!, index)
            if result != nil {
                return result
            }
            index += 1
            node = node?.next
        }
        
        return nil
    }

    /// Return the node at a given index
    ///
    /// - complexity: O(n)
    /// - parameter index: The index in the list
    ///
    /// - returns: The node at the provided index.
    public func nodeAt(index: Int) -> NodeType {
        precondition(index >= 0 && index < count, "Index \(index) out of bounds")
        
        let result = iterate {
            if $1 == index {
                return $0
            }
            
            return nil
        }
        
        return result!
    }

    /// Return the value at a given index
    ///
    /// - complexity: O(n)
    /// - parameter index: The index in the list
    ///
    /// - returns: The value at the provided index.
    public func valueAt(index: Int) -> T {
        let node = nodeAt(index: index)
        return node.value
    }
    
    /// Remove a give node from the list
    ///
    /// - complexity: O(1)
    /// - parameter node: The node to remove
    public func remove(node: NodeType) {
        let nextNode = node.next
        let previousNode = node.previous
        
        if node === start && node === end {
            start = nil
            end = nil
        }
        else if node === start {
            start = node.next
        } else if node === end {
            end = node.previous
        } else {
            previousNode?.next = nextNode
            nextNode?.previous = previousNode
        }
        
        count -= 1
        assert(
            (end != nil && start != nil && count >= 1) || (end == nil && start == nil && count == 0),
            "Internal invariant not upheld at the end of remove"
        )
    }
    
    /// Remove a give node from the list at a given index
    ///
    /// - complexity: O(n)
    /// - parameter atIndex: The index of the value to remove
    public func remove(atIndex index: Int) {
        precondition(index >= 0 && index < count, "Index \(index) out of bounds")
        
        // Find the node
        let result = iterate {
            if $1 == index {
                return $0
            }
            return nil
        }
        
        // Remove the node
        remove(node: result!)
    }

}

public struct LinkedListIterator<T: Equatable>: IteratorProtocol {
    public typealias Element = Node<T>
    
    /// The current node in the iteration
    private var currentNode: Element?
    
    public init(startNode: Element?) {
        currentNode = startNode
    }
    public mutating func next() -> LinkedListIterator.Element? {
        let node = currentNode
        currentNode = currentNode?.next
        
        return node
    }
}

extension LinkedList: Sequence {
    public typealias Iterator = LinkedListIterator<T>
    
    public func makeIterator() -> LinkedList.Iterator {
        let linkedListIterator = LinkedListIterator(startNode: start)
        return linkedListIterator
        //return LinkedListIterator(startNode: start)
    }
}
