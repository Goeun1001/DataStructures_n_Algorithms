# Tree

## Summary

1. Binary Tree
2. Binary Search Tree
3. AVL Tree
4. Tries

```swift
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
```

## 1. Binary Tree

```swift
var tree: BinaryNode<Int> = {
    let zero = BinaryNode(value: 0)
    let one = BinaryNode(value: 1)
    let five = BinaryNode(value: 5)
    let seven = BinaryNode(value: 7)
    
    seven.leftChild = one
    one.leftChild = zero
    one.rightChild = five

    return seven
}()

tree.traverseInOrder(visit: { print($0 )})
```

### Challenge 1

**Height of a Tree**

```swift
extension BinaryNode {
    public func height<T>(node: BinaryNode<T>?) -> Int {
        guard let node = node else { return -1 }
        return 1 + max(height(node: tree.leftChild), height(node: tree.rightChild))
    }
}
```



### Challenge 2

**Serialization**

```swift
extension BinaryNode {
    public func traversePreOrder2(visit: (Element?) -> Void) {
        visit(value)
        if let leftChild = leftChild {
            leftChild.traversePreOrder(visit: visit)
        } else {
            visit(nil)
        }
        if let rightChild = rightChild {
            rightChild.traversePreOrder(visit: visit)
        } else {
            visit(nil)
        }
    }
}

public func serialize<T>(node: BinaryNode<T>) -> [T?] {
    var array: [T?] = []
    node.traversePreOrder2 { array.append($0) }
    return array
}

public func deserialize<T>(array: inout [T?]) -> BinaryNode<T>? {
    guard !array.isEmpty else { return nil }
    guard let value = array.removeFirst() else {
        return nil
    }
    
    let node = BinaryNode(value: value)
    node.leftChild = deserialize(array: &array)
    node.rightChild = deserialize(array: &array)
    return node
}
```

## 2. Binary Search Tree

```swift
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
```

### Challenge 1

**Binary tree or binary search tree?**

```swift
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
```

### Challenge 2

**Equatable**

```swift
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
```

### Challenge 3

**Is it a subtree?**

```swift
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

```

# 3. AVL Tree

```swift
public class BinaryNode<Element> {
    public var value: Element
    public var leftChild: BinaryNode?
    public var rightChild: BinaryNode?
    public var height = 0
    
    public var balanceFactor: Int {
        leftHeight - rightHeight
    }
    
    public var leftHeight: Int {
        leftChild?.height ?? -1
    }
    
    public var rightHeight: Int {
        rightChild?.height ?? -1
    }
    
    public init(value: Element) {
        self.value = value
    }
}

extension AVLTree {
    private func insert(from node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element> {
        guard let node = node else {
            return BinaryNode(value: value)
        }
        if value < node.value {
            node.leftChild = insert(from: node.leftChild, value: value)
        } else {
            node.rightChild = insert(from: node.rightChild, value: value)
        }
        let balancedNode = balanced(node)
        balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1
        return balancedNode
    }
  
		private func leftRotate(_ node: BinaryNode<Element>) -> BinaryNode<Element> {
        let pivot = node.rightChild!
        node.rightChild = pivot.leftChild
        pivot.leftChild = node
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        return pivot
    }
    
    private func rightRotate(_ node: BinaryNode<Element>) -> BinaryNode<Element> {
        let pivot = node.leftChild!
        node.leftChild = pivot.rightChild
        pivot.rightChild = node
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        return pivot
    }
    
    private func rightLeftRotate(_ node: BinaryNode<Element>) -> BinaryNode<Element> {
        guard let rightChild = node.rightChild else {
            return node
        }
        node.rightChild = rightRotate(rightChild)
        return leftRotate(node)
    }
    
    private func leftRightRotate(_ node: BinaryNode<Element>) -> BinaryNode<Element> {
        guard let leftChild = node.leftChild else {
            return node
        }
        node.leftChild = leftRotate(leftChild)
        return rightRotate(node)
    }
    
    private func balanced(_ node: BinaryNode<Element>) -> BinaryNode<Element> {
        switch node.balanceFactor {
        case 2:
            if let leftChild = node.leftChild, leftChild.balanceFactor == -1 {
                return leftRightRotate(node)
            } else {
                return rightRotate(node)
            }
        case -2:
            if let rightChild = node.rightChild, rightChild.balanceFactor == 1 {
                return rightLeftRotate(node)
            } else {
                return leftRotate(node)
            }
        default:
            return node
        }
    }
}
```

### Challenge 1
**Number of leaves**

```swift
import Foundation

func leafNodes(inTreeOfHeight height: Int) -> Int {
  Int(pow(2.0, Double(height)))
}
```

### Challenge 2

**Number of nodes**

```swift
func nodes(inTreeOfHeight height: Int) -> Int {
  Int(pow(2, Double(height + 1))) - 1
}
```

### Challenge 3

**A tree traversal protocol**

```swift
protocol TraversableBinaryNode {
    
  associatedtype Element
  var value: Element { get }
  var leftChild: Self? { get }
  var rightChild: Self? { get }
  func traverseInOrder(visit: (Element) -> Void)
  func traversePreOrder(visit: (Element) -> Void)
  func traversePostOrder(visit: (Element) -> Void)
}

extension TraversableBinaryNode {
  
  func traverseInOrder(visit: (Element) -> Void) {
    leftChild?.traverseInOrder(visit: visit)
    visit(value)
    rightChild?.traverseInOrder(visit: visit)
  }
  
  func traversePreOrder(visit: (Element) -> Void) {
    visit(value)
    leftChild?.traversePreOrder(visit: visit)
    rightChild?.traversePreOrder(visit: visit)
  }
  
  func traversePostOrder(visit: (Element) -> Void) {
    leftChild?.traversePostOrder(visit: visit)
    rightChild?.traversePostOrder(visit: visit)
    visit(value)
  }
}

extension BinaryNode: TraversableBinaryNode {}
```

## 4. Tries

```swift
public class TrieNode<Key: Hashable> {
    public var key: Key?
    public weak var parent: TrieNode?
    public var children: [Key: TrieNode] = [:]
    public var isTerminating = false
    public init(key: Key?, parent: TrieNode?) {
        self.key = key
    }
}

public class Trie<CollectionType: Collection & Hashable> where CollectionType.Element: Hashable {
  
  public typealias Node = TrieNode<CollectionType.Element>
  
  private let root = Node(key: nil, parent: nil)
    
  public private(set) var collections: Set<CollectionType> = []
    
  public var count: Int {
    collections.count
  }
  
  public var isEmpty: Bool {
    collections.isEmpty
  }
  public init() {}
  
  public func insert(_ collection: CollectionType) {
    var current = root
    for element in collection {
      if current.children[element] == nil {
        current.children[element] = Node(key: element, parent: current)
      }
      current = current.children[element]!
    }
    if current.isTerminating {
      return
    } else {
      current.isTerminating = true
      collections.insert(collection)
    }
  }
  
  public func contains(_ collection: CollectionType) -> Bool {
    var current = root
    for element in collection {
      guard let child = current.children[element] else {
        return false
      }
      current = child
    }
    return current.isTerminating
  }
  
  public func remove(_ collection: CollectionType) {
    var current = root
    for element in collection {
      guard let child = current.children[element] else {
        return
      }
      current = child
    }
    guard current.isTerminating else {
      return
    }
    current.isTerminating = false
    collections.remove(collection)
    while let parent = current.parent, current.children.isEmpty && !current.isTerminating {
      parent.children[current.key!] = nil
      current = parent
    }
  }
}

public extension Trie where CollectionType: RangeReplaceableCollection {
  
  func collections(startingWith prefix: CollectionType) -> [CollectionType] {
    var current = root
    for element in prefix {
      guard let child = current.children[element] else {
        return []
      }
      current = child
    }
    return collections(startingWith: prefix, after: current)
  }
  
  private func collections(startingWith prefix: CollectionType, after node: Node) -> [CollectionType] {
    
    // 1
    var results: [CollectionType] = []
    
    if node.isTerminating {
      results.append(prefix)
    }
    
    // 2
    for child in node.children.values {
      var prefix = prefix
      prefix.append(child.key!)
      results.append(contentsOf: collections(startingWith: prefix, after: child))
    }
    
    return results
  }
}
```

