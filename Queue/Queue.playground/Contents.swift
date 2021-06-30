public protocol Queue {
    associatedtype Element
    mutating func enqueue(element: Element) -> Bool
    mutating func dequeue() -> Element?
    var isEmpty: Bool { get }
    var peek: Element? { get }
}

public struct ArrayQueue<T>: Queue {
    private var array: [T] = []
    public init() {}
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public var peek: T? {
        array.first
    }
    
    public mutating func enqueue(element: T) -> Bool {
        array.append(element)
        return true
    }
    
    public mutating func dequeue() -> T? {
        isEmpty ? nil : array.removeFirst()
    }
}

public struct RingBuffer<T> {
    private var array: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    
    public init(count: Int) {
        array = [T?](repeating: nil, count: count)
    }
    
    /* Returns false if out of space. */
    @discardableResult
    public mutating func write(_ element: T) -> Bool {
        guard !isFull else { return false }
        defer {
            writeIndex += 1
        }
        array[wrapped: writeIndex] = element
        return true
    }
    
    /* Returns nil if the buffer is empty. */
    public mutating func read() -> T? {
        guard !isEmpty else { return nil }
        defer {
            array[wrapped: readIndex] = nil
            readIndex += 1
        }
        return array[wrapped: readIndex]
    }
    
    private var availableSpaceForReading: Int {
        return writeIndex - readIndex
    }
    
    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }
    
    public var first: T? {
        return array[wrapped: readIndex]
    }
    
    private var availableSpaceForWriting: Int {
        return array.count - availableSpaceForReading
    }
    
    public var isFull: Bool {
        return availableSpaceForWriting == 0
    }
}

private extension Array {
    subscript (wrapped index: Int) -> Element {
        get {
            return self[index % count]
        }
        set {
            self[index % count] = newValue
        }
    }
}

public struct QueueRingBuffer<T>: Queue {
    private var ringBuffer: RingBuffer<T>
    
    public init(count: Int) {
        ringBuffer = RingBuffer<T>(count: count)
    }
    
    public var isEmpty: Bool {
        ringBuffer.isEmpty
    }
    
    public var peek: T? {
        ringBuffer.first
    }
    
    public mutating func enqueue(element: T) -> Bool {
        ringBuffer.write(element)
    }
    
    public mutating func dequeue() -> T? {
        ringBuffer.read()
    }
}

extension ArrayQueue {
    public mutating func reversed() -> ArrayQueue {
        self.array = array.reversed()
        return self
    }
    
    public mutating func reversed2() -> ArrayQueue {
        var queue = self
        var stack = Stack<T>()
        while let element = queue.dequeue() {
            stack.push(element)
        }
        while let element = stack.pop() {
            queue.enqueue(element: element)
        }
        return queue
    }
}

public enum Direction {
    case front
    case back
}

public protocol Deque {
    associatedtype Element
    mutating func enqueue(element: Element, to direction: Direction) -> Bool
    mutating func dequeue(from direction: Direction) -> Element?
    var isEmpty: Bool { get }
    func peek(from direction: Direction) -> Element?
}

public struct DequeImpl<T>: Deque {
    private var array: [T] = []
    public init() {}
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public func peek(from direction: Direction) -> Element? {
        array.first
    }
    
    public mutating func enqueue(element: T, to direction: Direction) -> Bool {
        if direction == .front {
            self.array.insert(element, at: 0)
            return true
        } else {
            self.array.append(element)
            return true
        }
    }
    
    public mutating func dequeue(from direction: Direction) -> T? {
        if direction == .front {
            return self.array.removeFirst()
        } else {
            return self.array.removeLast()
        }
    }
}
