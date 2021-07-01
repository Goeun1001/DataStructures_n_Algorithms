public protocol Queue {
    associatedtype Element
    mutating func enqueue(element: Element) -> Bool
    mutating func dequeue() -> Element?
    var isEmpty: Bool { get }
    var peek: Element? { get }
}

public struct PriorityQueue<Element: Equatable>: Queue {
    private var heap: Heap<Element>
    
    public init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
        heap = Heap(sort: sort, elements: elements)
    }
    
    public mutating func enqueue(element: Element) -> Bool {
        heap.insert(element)
        return true
    }
    
    public mutating func dequeue() -> Element? {
        heap.remove()
    }
    
    public var isEmpty: Bool {
        heap.isEmpty
    }
    
    public var peek: Element? {
        heap.peek()
    }
}

// Challenge 1
// Array-based priority queue
public struct PriorityArrayQueue<Element: Equatable>: Queue {
    private var elements: [Element] = []
    let sort: (Element, Element) -> Bool
    
    public init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
        self.sort = sort
        self.elements = elements
        self.elements.sort(by: sort)
    }
    
    public var isEmpty: Bool {
        return elements.isEmpty
    }
    
    public var peek: Element? {
        return elements.first
    }
    
    public mutating func enqueue(element: Element) -> Bool {
        for (index, otherElement) in elements.enumerated() {
            if sort(element, otherElement) {
                elements.insert(element, at: index)
                return true
            }
        }
        elements.append(element)
        return true
    }
    
    public mutating func dequeue() -> Element? {
        isEmpty ? nil : elements.removeFirst()
    }
    
}

// Challenge 2
// Prioritize a waitlist
public struct Person: Equatable {
    let name: String
    let age: Int
    let isMilitary: Bool
}

func tswiftSort(person1: Person, person2: Person) -> Bool {
    if person1.isMilitary == person2.isMilitary {
        return person1.age > person2.age
    }
    return person1.isMilitary
}


let p = Person(name: "Josh", age: 21, isMilitary: true)
let p2 = Person(name: "Jake", age: 22, isMilitary: true)
let p3 = Person(name: "Clay", age: 28, isMilitary: false)
let p4 = Person(name: "Cindy", age: 28, isMilitary: false)
let p5 = Person(name: "Sabrina", age: 30, isMilitary: false)

let waitlist = [p, p2, p3, p4, p5]

var priorityQueue = PriorityQueue(sort: tswiftSort, elements: waitlist)
while !priorityQueue.isEmpty {
    print(priorityQueue.dequeue()!)
}


// Challenge 3
// Minizimze recharge stops
struct ChargingStation {
    /// Distance from start location.
    let distance: Int
    /// The amount of electricity the station has to charge a car.
    /// 1 capacity = 1 mile
    let chargeCapacity: Int
}

enum DestinationResult {
    /// Able to reach your destination with the minimum number of stops.
    case reachable(rechargeStops: Int)
    /// Unable to reach your destination.
    case unreachable
}

/// Returns the minimum number of charging stations an electric vehicle needs to reach it's destination.
/// - Parameter target: the distance in miles the vehicle needs to travel.
/// - Parameter startCharge: the starting charge you have to start the journey.
/// - Parameter stations: the charging stations along the way.
func minRechargeStops(target: Int, startCharge: Int, stations: [ChargingStation]) -> DestinationResult {
    guard startCharge <= target else { return .reachable(rechargeStops: 0) }
    
    // Keeps track of the minimum number of stops needed to reach destination
    var minStops = -1
    // Keeps track of the vehicle's current charge on the journey.
    var currentCharge = 0
    // Tracks the number of stations passed.
    var currentStation = 0
    // Keeps track of all the station's charge capacity.
    // Responsibility for provide us the station with the highest charging capacity.
    // Initialize the priority queue with the vehicle's starting charge capacity.
    // The priority queue represents all the charging stations that is reachable.
    var chargePriority = PriorityQueue(sort: >, elements: [startCharge])
    
    while !chargePriority.isEmpty {
        guard let charge = chargePriority.dequeue() else {
            return .unreachable
        }
        currentCharge += charge
        minStops += 1
        
        if currentCharge >= target {
            return .reachable(rechargeStops: minStops)
        }
        
        while currentStation < stations.count &&
                currentCharge >= stations[currentStation].distance {
            let distance = stations[currentStation].chargeCapacity
            _ = chargePriority.enqueue(element: distance)
            currentStation += 1
        }
    }
    return .unreachable
}


// Sample Tests
let stations = [ChargingStation(distance: 10, chargeCapacity: 60),
                ChargingStation(distance: 20, chargeCapacity: 30),
                ChargingStation(distance: 30, chargeCapacity: 30),
                ChargingStation(distance: 60, chargeCapacity: 40)]

minRechargeStops(target: 100, startCharge: 10, stations: stations)



public struct Heap<Element: Equatable> {
    var elements: [Element] = []
    let sort: (Element, Element) -> Bool
    
    init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
        self.sort = sort
        self.elements = elements
        buildHeap()
    }
    
    var isEmpty: Bool {
        elements.isEmpty
    }
    
    var count: Int {
        elements.count
    }
    
    func peek() -> Element? {
        elements.first
    }
    
    mutating public func buildHeap() {
        if !elements.isEmpty {
            for i in stride(from: elements.count / 2 - 1, through: 0, by: -1) {
                siftDown(from: i)
            }
        }
    }
    
    func leftChildIndex(ofParentAt index: Int) -> Int {
        (2 * index) + 1
    }
    
    func rightChildIndex(ofParentAt index: Int) -> Int {
        (2 * index) + 2
    }
    
    func parentIndex(ofChildAt index: Int) -> Int {
        (index - 1) / 2
    }
    
    mutating func remove() -> Element? {
        guard !isEmpty else {
            return nil
        }
        elements.swapAt(0, count - 1)
        defer {
            siftDown(from: 0)
        }
        return elements.removeLast()
    }
    
    mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = leftChildIndex(ofParentAt: parent)
            let right = rightChildIndex(ofParentAt: parent)
            var candidate = parent
            if left < count && sort(elements[left], elements[candidate]) {
                candidate = left
            }
            if right < count && sort(elements[right], elements[candidate]) {
                candidate = right
            }
            if candidate == parent {
                return
            }
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
    
    mutating func insert(_ element: Element) {
        elements.append(element)
        siftUp(from: elements.count - 1)
    }
    
    mutating func siftUp(from index: Int) {
        var child = index
        var parent = parentIndex(ofChildAt: child)
        while child > 0 && sort(elements[child], elements[parent]) {
            elements.swapAt(child, parent)
            child = parent
            parent = parentIndex(ofChildAt: child)
        }
    }
    
    mutating func remove(at index: Int) -> Element? {
        guard index < elements.count else {
            return nil // 1
        }
        if index == elements.count - 1 {
            return elements.removeLast() // 2
        } else {
            elements.swapAt(index, elements.count - 1) // 3
            defer {
                siftDown(from: index) // 5
                siftUp(from: index)
            }
            return elements.removeLast() // 4
        }
    }
    
    func index(of element: Element, startingAt i: Int) -> Int? {
        if i >= count {
            return nil
        }
        if sort(element, elements[i]) {
            return nil
        }
        if element == elements[i] {
            return i
        }
        if let j = index(of: element, startingAt: leftChildIndex(ofParentAt: i)) {
            return j
        }
        if let j = index(of: element, startingAt: rightChildIndex(ofParentAt: i)) {
            return j
        }
        return nil
    }
}
