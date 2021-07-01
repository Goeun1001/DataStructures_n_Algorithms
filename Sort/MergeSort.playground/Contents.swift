import Foundation

public func mergeSort<Element>(array: [Element]) -> [Element] where Element: Comparable {
    guard array.count > 1 else { return array }
    let middle = array.count / 2
    let left = Array(array[..<middle])
    let right = Array(array[middle...])
    return merge(left, right)
}

private func merge<Element>(_ left: [Element], _ right: [Element]) -> [Element] where Element: Comparable {
    var leftIndex = 0
    var rightIndex = 0
    var result: [Element] = []
    
    while leftIndex < left.count && rightIndex < right.count {
        let leftElement = left[leftIndex]
        let rightElement = right[rightIndex]
        if leftElement < rightElement {
            result.append(leftElement)
            leftIndex += 1
        } else if leftElement > rightElement {
            result.append(rightElement)
            rightIndex += 1
        } else {
            result.append(leftElement)
            leftIndex += 1
            result.append(rightElement)
            rightIndex += 1
        }
    }
    
    if leftIndex < left.count {
        result.append(contentsOf: left[leftIndex...])
    }
    
    if rightIndex < right.count {
        result.append(contentsOf: right[rightIndex...])
    }
    return result
}

// Challenge 1
// Speeding up appends
let size = 1024
var values: [Int] = []
values.reserveCapacity(size)
for i in 0 ..< size {
    values.append(i)
}

// Challenge 2
// Merge two sequences
func merge<T: Sequence>(first: T, second: T) -> AnySequence<T.Element> where T.Element: Comparable {
    var result: [T.Element] = []
    
    var firstIterator = first.makeIterator()
    var secondIterator = second.makeIterator()
    
    var firstNextValue = firstIterator.next()
    var secondNextValue = secondIterator.next()
    
    while let first = firstNextValue, let second = secondNextValue {
        if first < second {
            result.append(first)
            firstNextValue = firstIterator.next()
        } else if second < first {
            result.append(second)
            secondNextValue = secondIterator.next()
        } else {
            result.append(first)
            result.append(second)
            firstNextValue = firstIterator.next()
            secondNextValue = secondIterator.next()
        }
    }
    
    while let first = firstNextValue {
        result.append(first)
        firstNextValue = firstIterator.next()
    }
    
    while let second = secondNextValue {
        result.append(second)
        secondNextValue = secondIterator.next()
    }
    
    return AnySequence<T.Element>(result)
}
