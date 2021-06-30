public class Node<Value> {
    public var value: Value
    public var next: Node?
    
    public init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        guard let next = next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next) + " "
    }
}

public struct LinkedList<Value> {
    public var head: Node<Value>?
    public var tail: Node<Value>?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public mutating func push(value: Value) { // insert at head
        copyNodes()
        head = Node(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }
    
    public mutating func append(value: Value) { // insert at tail
        copyNodes()
        guard !isEmpty else {
            push(value: value)
            return
        }
        
        tail!.next = Node(value: value)
        tail = tail!.next
    }
    
    // Book
    public func node(at index: Int) -> Node<Value>? { // returns a node at given index
        var currentNode = head
        var currentIndex = 0
        
        while currentNode != nil && currentIndex < index {
            currentNode = currentNode?.next
            currentIndex += 1
            
        }
        return currentNode
    }
    
    @discardableResult
    public mutating func insert(value: Value, after node: Node<Value>) -> Node<Value> { // insert after a node
        copyNodes()
        guard tail !== node else {
            append(value: value)
            return tail!
        }
        
        node.next = Node(value: value, next: node.next)
        return node.next!
    }
    
    @discardableResult
    public mutating func pop() -> Value? { // remove at head
        copyNodes()
        defer {
            head = head?.next
            if isEmpty {
                tail = nil
            }
        }
        
        return head?.value
    }
    
    @discardableResult
    public mutating func removeLast() -> Value? { // remove at tail
        guard let head = head else { return nil }
        
        guard head.next != nil else { return pop() }
        
        copyNodes()
        
        var prev = head
        var current = head
        
        while let next = current.next {
            prev = current
            current = next
        }
        
        prev.next = nil
        tail = prev
        return current.value
    }
    
    @discardableResult
    public mutating func remove(after node: Node<Value>) -> Value? { // remove the immediate next node
        guard let node = copyNodes(returningCopyOf: node) else { return nil }
        defer {
            if node.next === tail {
                tail = node
            }
            node.next = node.next?.next
        }
        return node.next?.value
    }
    
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else { return "Empty List" }
        return String(describing: head)
    }
}

extension LinkedList : Collection {
    public struct Index: Comparable {
        public var node: Node<Value>?
        
        static public func ==(lhs: Index, rhs: Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }
        
        static public func <(lhs: Index, rhs: Index) -> Bool {
            guard lhs != rhs else {
                return false
            }
            let nodes = sequence(first: lhs.node) { $0?.next }
            return nodes.contains { $0 === rhs.node }
        }
    }
    
    public var startIndex: Index {
        Index(node: head)
    }
    
    public var endIndex: Index {
        Index(node: tail?.next)
    }
    
    public func index(after i: Index) -> Index {
        Index(node: i.node?.next)
    }
    
    public subscript(position: Index) -> Value {
        position.node!.value
    }
}

extension LinkedList {
    private mutating func copyNodes() {
        guard !isKnownUniquelyReferenced(&head) else { return }
        guard var oldNode = head else {
            return
        }
        
        head = Node(value: oldNode.value)
        var newNode = head
        
        while let nextOldNode = oldNode.next {
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            
            oldNode = nextOldNode
        }
        
        tail = newNode
    }
    
    private mutating func copyNodes(returningCopyOf node: Node<Value>?) -> Node<Value>? {
        guard !isKnownUniquelyReferenced(&head) else { return nil }
        guard var oldNode = head else { return nil }
        
        head = Node(value: oldNode.value)
        var newNode = head
        var nodeCopy: Node<Value>?
        
        while let nextOldNode = oldNode.next {
            if oldNode === node {
                nodeCopy = newNode
            }
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            oldNode = nextOldNode
        }
        
        return nodeCopy
    }
}

extension LinkedList {
    // Challenge 1
    // print in reverse
    private func printInReverse<T>(node: Node<T>?) {
        guard let node = node else { return }
        printInReverse(node: node.next)
        print(node.value)
    }
    
    public func printInReverse<T>(list: LinkedList<T>) {
        printInReverse(node: list.head)
    }
}

extension LinkedList {
    // Challenge 2
    // Find the middle node
    
    public func getMiddle<T>(list: LinkedList<T>) -> Node<T>? {
        var slow = list.head
        var fast = list.head
        
        while let nextFast = fast?.next {
            fast = nextFast.next
            slow = slow?.next
        }
        
        return slow
    }
}

extension LinkedList {
    // Challenge 3
    // Reverse a linked list
    public mutating func reverse() {
        var tmpList = LinkedList<Value>()
        for value in self {
            tmpList.push(value: value)
        }
        
        head = tmpList.head
    }
    
    public mutating func reverse2() {
        tail = head
        var prev = head
        var curernt = head?.next
        prev?.next = nil
        
        while curernt != nil {
            let next = curernt?.next
            curernt?.next = prev
            prev = curernt
            curernt = next
        }
        
        head = prev
    }
}

func mergeSorted<T: Comparable>(_ left: LinkedList<T>,
                                _ right: LinkedList<T>) -> LinkedList<T> {
    // Challenge 4
    // Mergo two lists
    guard !left.isEmpty else {
        return right
    }
    
    guard !right.isEmpty else {
        return left
    }
    
    var newHead: Node<T>?
    var tail: Node<T>?
    
    var currentLeft = left.head
    var currentRight = right.head
    
    if let leftNode = currentLeft, let rightNode = currentRight {
        if leftNode.value < rightNode.value {
            newHead = leftNode
            currentLeft = leftNode.next
        } else {
            newHead = rightNode
            currentRight = rightNode.next
        }
        tail = newHead
    }
    
    while let leftNode = currentLeft, let rightNode = currentRight {
        if leftNode.value < rightNode.value {
            tail?.next = leftNode
            currentLeft = leftNode.next
        } else {
            tail?.next = rightNode
            currentRight = rightNode.next
        }
        tail = tail?.next
    }
    
    if let leftNodes = currentLeft {
        tail?.next = leftNodes
    }
    
    if let rightNodes = currentRight {
        tail?.next = rightNodes
    }
    
    var list = LinkedList<T>()
    list.head = newHead
    list.tail = {
        while let next = tail?.next {
            tail = next
        }
        return tail
    }()
    return list
}

extension LinkedList where Value: Equatable {
    // Challenge 5
    // Remove all occurrencees
    mutating func removeAll(_ value: Value) {
        while let head = self.head, head.value == value {
            self.head = head.next
        }
        var prev = head
        var current = head?.next
        while let currentNode = current {
            if currentNode.next == nil {
                tail
            }
            guard currentNode.value != value else {
                prev?.next = currentNode.next
                current = prev?.next
                continue
            }
            prev = current
            current = current?.next
        }
        tail = prev
    }
}
