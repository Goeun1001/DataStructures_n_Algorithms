# Stack

```swift
public struct Stack<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public func peek() -> T? {
        return array.last
    }
    
    public var top: T? {
        return array.last // is equal to 'return peek() == nil'
    }
}
```



## Challange 1

**Reverse an Array**

```swift
public func reverse() -> [T] {
    return array.reversed()
}
```



## Chanllange 2

**Balance the parentheses**

h((e))llo(world)() -> balanced parentheses
(hello world // unbalanced parentheses

```swift
func checkParentheses(string: String) -> Bool {
    var stack = Stack<Character>()
    
    for character in string {
        if character == "(" {
            stack.push(character)
        } else if character == ")" {
            if stack.isEmpty {
                return false
            } else {
                stack.pop()
            }
        }
    }
    return stack.isEmpty
}
```

