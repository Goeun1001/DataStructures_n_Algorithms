public func bubbleSort<Element>(array: inout [Element]) where Element: Comparable {
    guard array.count >= 2 else { return }
    
    for end in (1..<array.count).reversed() {
        var swapped = false
        
        for current in 0..<end {
            if array[current] > array[current + 1] {
                array.swapAt(current, current + 1)
                swapped = true
            }
        }
        if !swapped { return }
    }
}

public func bubbleSort<CollectionType>(_ collection: inout CollectionType)
where CollectionType: MutableCollection, CollectionType.Element: Comparable {
    guard collection.count >= 2 else {
        return
    }
    for end in collection.indices.reversed() {
        var swapped = false
        var current = collection.startIndex
        while current < end {
            let next = collection.index(after: current)
            if collection[current] > collection[next] {
                collection.swapAt(current, next)
                swapped = true
            }
            current = next
        }
        if !swapped {
            return
        }
    }
}

public func selectionSort<Element>(array: inout [Element]) where Element: Comparable {
    guard array.count >= 2 else { return }
    
    for current in 0..<(array.count - 1) {
        var lowest = current
        
        for other in (current + 1)..<array.count {
            if array[lowest] > array[other] {
                lowest = other
            }
        }
        
        if lowest != current {
            array.swapAt(lowest, current)
        }
    }
}

public func selectionSort<CollectionType>(_ collection: inout CollectionType)
where CollectionType: MutableCollection, CollectionType.Element: Comparable {
    guard collection.count >= 2 else {
        return
    }
    for current in collection.indices {
        var lowest = current
        var other = collection.index(after: current)
        while other < collection.endIndex {
            if collection[lowest] > collection[other] {
                lowest = other
            }
            other = collection.index(after: other)
        }
        if lowest != current {
            collection.swapAt(lowest, current)
        }
    }
}

public func insertionSort<Element>(array: inout [Element]) where Element: Comparable {
    guard array.count >= 2 else { return }
    
    for current in 1..<array.count {
        for shifting in (1...current).reversed() {
            if array[shifting] < array[shifting - 1] {
                array.swapAt(shifting, shifting - 1)
            } else {
                break
            }
        }
    }
}

public func insertionSort<CollectionType>(_ collection: inout CollectionType)
where CollectionType: BidirectionalCollection & MutableCollection, CollectionType.Element: Comparable {
    guard collection.count >= 2 else {
        return
    }
    for current in collection.indices {
        var shifting = current
        while shifting > collection.startIndex {
            let previous = collection.index(before: shifting)
            if collection[shifting] < collection[previous] {
                collection.swapAt(shifting, previous)
            } else {
                break
            }
            shifting = previous
        }
    }
}


// Challnge 1
// Group elements
extension MutableCollection where Self: BidirectionalCollection, Element: Equatable {
    mutating func rightAlign(value: Element) {
        var left = startIndex
        var right = index(before: endIndex)
        
        while left < right {
            while self[right] == value {
                formIndex(before: &right)
            }
            while self[left] != value {
                formIndex(after: &left)
            }
            guard left < right else {
                return
            }
            swapAt(left, right)
        }
    }
}


// Challenge 2
// Find a duplicate
extension Sequence where Element: Hashable {
    var firstDuplicate: Element? {
        var found: Set<Element> = []
        for value in self {
            if found.contains(value) {
                return value
            } else {
                found.insert(value)
            }
        }
        return nil
    }
}

// Challenge 3
// Reverse a collection
extension MutableCollection where Self: BidirectionalCollection {
    mutating func reverse() {
        var left = startIndex
        var right = index(before: endIndex)
        
        while left < right {
            swapAt(left, right)
            formIndex(after: &left)
            formIndex(before: &right)
        }
    }
}
