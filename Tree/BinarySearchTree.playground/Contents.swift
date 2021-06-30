public class BinaryNode<Element> {
    public var value: Element
    public var leftChild: BinaryNode?
    public var rightChild: BinaryNode?
    
    public init(value: Element) {
        self.value = value
    }
}

extension BinaryNode {
    public func traverseInOrder(visit: (Element) -> Void) {
        leftChild?.traverseInOrder(visit: visit)
        visit(value)
        rightChild?.traverseInOrder(visit: visit)
    }
    
    public func traversePreOrder(visit: (Element) -> Void) {
        visit(value)
        leftChild?.traversePreOrder(visit: visit)
        rightChild?.traversePreOrder(visit: visit)
    }
    
    public func traversePostOrder(visit: (Element) -> Void) {
        leftChild?.traversePostOrder(visit: visit)
        rightChild?.traversePostOrder(visit: visit)
        visit(value)
    }
}

public struct BinarySearchTree<Element: Comparable> {
    public private(set) var root: BinaryNode<Element>?
    public init() {}
}

extension BinarySearchTree {
    public mutating func insert(value: Element) {
        root = insert(from: root, value: value)
    }
    
    private func insert(from node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element> {
        guard let node = node else {
            return BinaryNode(value: value)
        }
        
        if value < node.value {
            node.leftChild = insert(from: node.leftChild, value: value)
        } else {
            node.rightChild = insert(from: node.rightChild, value: value)
        }
        return node
    }
    
    public func contains(value: Element) -> Bool {
        guard let root = root else { return false }
        var found = false
        root.traverseInOrder {
            if $0 == value {
                found = true
            }
        }
        return found
    }
    
    public func contains2(value: Element) -> Bool {
        var current = root
        
        while let node = current {
            if node.value == value { return true }
            if value < node.value { current = node.leftChild } else { current = node.rightChild }
        }
        return false
    }
}

private extension BinaryNode {
    var min: BinaryNode {
        leftChild?.min ?? self
    }
}

extension BinarySearchTree {
    public mutating func remove(value: Element) {
        root = remove(node: root, value: value)
    }
    
    private func remove(node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element>? {
        guard let node = node else { return nil }
        if value == node.value {
            if node.leftChild == nil && node.rightChild == nil {
                return nil
            }
            if node.leftChild == nil {
                return node.rightChild
            }
            if node.rightChild == nil {
                return node.leftChild
            }
            
            node.value = node.rightChild!.min.value
            node.rightChild = remove(node: node.rightChild, value: node.value)
        } else if value < node.value {
            
        } else {
            node.rightChild = remove(node: node.rightChild, value: value)
        }
        return node
    }
}

var tree: BinarySearchTree<Int> = {
    var bst = BinarySearchTree<Int>()
    bst.insert(value: 3)
    bst.insert(value: 1)
    bst.insert(value: 4)
    bst.insert(value: 0)
    bst.insert(value: 2)
    bst.insert(value: 5)
    return bst
}()

extension BinaryNode where Element: Comparable {
    var isBinarySearchTree: Bool {
        isBST(tree: self, min: nil, max: nil)
    }
    
    private func isBST(tree: BinaryNode<Element>?, min: Element?, max: Element?) -> Bool {
        guard let tree = tree else { return true }
        if let min = min, tree.value <= min {
            return false
        } else if let max = max, tree.value > max {
            return false
        }
        
        return isBST(tree: tree.leftChild, min: min, max: tree.value) && isBST(tree: tree.rightChild, min: tree.value, max: max)
    }
}

extension BinarySearchTree: Equatable {
    public static func ==(lhs: BinarySearchTree, rhs: BinarySearchTree) -> Bool {
        isEqual(node1: lhs.root, node2: rhs.root)
    }
    
    private static func isEqual<Element: Equatable>(node1: BinaryNode<Element>?, node2: BinaryNode<Element>?) -> Bool {
        guard let leftNode = node1, let rightNode = node2 else {
            return node1 == nil && node2 == nil
        }
        
        return leftNode.value == rightNode.value && isEqual(node1: leftNode.leftChild, node2: rightNode.leftChild) && isEqual(node1: leftNode.rightChild, node2: rightNode.rightChild)
    }
}


extension BinarySearchTree where Element: Hashable {
    public func contains(subtree:BinarySearchTree) -> Bool {
        var set: Set<Element> = []
        root?.traverseInOrder { set.insert($0) }
        var isEqual = true
        subtree.root?.traverseInOrder {
            isEqual = isEqual && set.contains($0)
        }
        return isEqual
    }
}
