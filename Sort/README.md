### Sort

## Summary

1. Bubble sort
2. Selection sort
3. Insertion sort



## Bubble sort

![img](https://media.vlpt.us/images/hwamoc/post/4aec7cdc-5de7-4af5-89e8-15ed4ca9e549/%EB%B2%84%EB%B8%941.gif)

```swift
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
```

## Selection sort

![img](https://media.vlpt.us/images/hwamoc/post/4adce14a-bb45-4c39-8253-ae5665991156/%EC%84%A0%ED%83%9D1.gif)

```swift
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
```

## Insertion sort

![img](https://media.vlpt.us/images/hwamoc/post/4baaa2bc-d48a-4f3b-a063-6538f6f59971/%EC%82%BD%EC%9E%851.gif)

```swift
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
```

### Challnge 1

**Group elements**

```swift
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
```

### Challenge 2

**Find a. uplicate**

```swift
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
```

### Challenge 3

**Reverse a collection**

```swift
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
```

## Merge sort

![합병 정렬(Merge sort)을 구현해보자](https://blog.kakaocdn.net/dn/cIltay/btqGgEIMqaU/SqtfkiPGHmb9CTofYJAFHk/img.png)

```swift
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
```

### Challenge 1

**Speeding up appends**

```swift
let size = 1024
var values: [Int] = []
values.reserveCapacity(size)
for i in 0 ..< size {
    values.append(i)
}
```

### Challenge 2

**Merge two sequences**

```swift
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
```

## Radix sort

![img](https://t1.daumcdn.net/cfile/tistory/99A6D33359CE331015)

![img](https://t1.daumcdn.net/cfile/tistory/9957483359CE33AB14)

![img](https://t1.daumcdn.net/cfile/tistory/9913633359CE34C223)

![img](https://t1.daumcdn.net/cfile/tistory/99C8DB3359CE35D412)

```swift
extension Array where Element == Int {
    public mutating func radixSort() {
        let base = 10
        var done = false
        var digits = 1
        while !done {
            done = true
            var buckets: [[Int]] = .init(repeating: [], count: base)
            forEach {
                number in
                let remainingPart = number / digits
                let digit = remainingPart % base
                buckets[digit].append(number)
                if remainingPart > 0 {
                    done = false
                }
            }
            digits *= base
            self = buckets.flatMap { $0 }
        }
    }
}
```

### Challenge 1
**Most singificant digit**

```swift
extension Int {
    var digits: Int {
        var count = 0
        var num = self
        while num != 0 {
            count += 1
            num /= 10
        }
        return count
    }
    
    func digit(atPosition position: Int) -> Int? {
        guard position < digits else {
            return nil
        }
        var num = self
        let correctedPosition = Double(position + 1)
        while num / Int(pow(10.0, correctedPosition)) != 0 {
            num /= 10
        }
        return num % 10
    }
}


extension Array where Element == Int {
    private var maxDigits: Int {
        self.max()?.digits ?? 0
    }
    
    mutating func lexicographicalSort() {
        self = msdRadixSorted(self, 0)
    }
    
    private func msdRadixSorted(_ array: [Int], _ position: Int) -> [Int] {
        guard position < array.maxDigits else {
            return array
        }
        
        var buckets: [[Int]] = .init(repeating: [], count: 10)
        var priorityBucket: [Int] = []
        
        array.forEach { number in
            guard let digit = number.digit(atPosition: position) else {
                priorityBucket.append(number)
                return
            }
            buckets[digit].append(number)
        }
        
        priorityBucket.append(contentsOf: buckets.reduce(into: []) {
            result, bucket in
            guard !bucket.isEmpty else {
                return
            }
            result.append(contentsOf: msdRadixSorted(bucket, position + 1))
        })
        return priorityBucket
    }
}
```

## Heap sort

```swift
extension Heap {
    func sorted() -> [Element] {
        var heap = Heap(sort: sort, elements: elements)
        for index in heap.elements.indices.reversed() {
            heap.elements.swapAt(0, index)
            heap.siftDown(from: 0, upTo: index)
        }
        return heap.elements
    }
}
```

### Challenge 1

**Add heap sort to Array**

```swift
extension Array where Element: Comparable {
    mutating func heapSort() {
        // Build Heap
        if !isEmpty {
            for i in stride(from: count / 2 - 1, through: 0, by: -1) {
                siftDown(from: i, upTo: count)
            }
        }
        
        // Perform Heap Sort.
        for index in indices.reversed() {
            swapAt(0, index)
            siftDown(from: 0, upTo: index)
        }
    }
}
```

## Quick sort

```swift
public func quicksortNaive<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else {
        return a
    }
    let pivot = a[a.count / 2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    return quicksortNaive(less) + equal + quicksortNaive(greater)
}
```

### Lomuto

![img](https://blog.kakaocdn.net/dn/FrUjm/btqvsxNRdVC/Yfoxb7uopcKEkLKZGKLXO0/img.png)

```swift
public func partitionLomuto<T: Comparable>(_ a: inout [T], low: Int, high: Int) -> Int {
    let pivot = a[high]
    var i = low
    for j in low..<high {
        if a[j] <= pivot {
            a.swapAt(i, j)
            i += 1
        }
    }
    a.swapAt(i, high)
    return i
}

public func quicksortLomuto<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let pivot = partitionLomuto(&a, low: low, high: high)
        quicksortLomuto(&a, low: low, high: pivot - 1)
        quicksortLomuto(&a, low: pivot + 1, high: high)
    }
}
```



### Hoare

![챕터5-3. 정렬 | 퀵 정렬(Quick Sort) - Hoare(호어) / Lomuto(로무토) 분할 알고리즘](https://blog.kakaocdn.net/dn/rYYgz/btqvslUpbDD/sVAPFxoC8bLImrj2gmGtZ0/img.png)

```swift
public func partitionHoare<T: Comparable>(_ a: inout [T], low: Int, high: Int) -> Int {
    let pivot = a[low]
    var i = low - 1
    var j = high + 1
    
    while true {
        repeat { j -= 1 } while a[j] > pivot
        repeat { i += 1 } while a[i] < pivot
        
        if i < j {
            a.swapAt(i, j)
        } else {
            return j
        }
    }
}

public func quicksortHoare<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let p = partitionHoare(&a, low: low, high: high)
        quicksortHoare(&a, low: low, high: p)
        quicksortHoare(&a, low: p + 1, high: high)
    }
}
```

### Median

```swift
public func medianOfThree<T: Comparable>(_ a: inout [T], low: Int, high: Int) -> Int {
    let center = (low + high) / 2
    if a[low] > a[center] {
        a.swapAt(low, center)
    }
    if a[low] > a[high] {
        a.swapAt(low, high)
    }
    if a[center] > a[high] {
        a.swapAt(center, high)
    }
    return center
}

public func quickSortMedian<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let pivotIndex = medianOfThree(&a, low: low, high: high)
        a.swapAt(pivotIndex, high)
        let pivot = partitionLomuto(&a, low: low, high: high)
        quicksortLomuto(&a, low: low, high: pivot - 1)
        quicksortLomuto(&a, low: pivot + 1, high: high)
    }
}
```

### Dutch flag

```swift
public func partitionDutchFlag<T: Comparable>(_ a: inout [T], low: Int, high: Int, pivotIndex: Int) -> (Int, Int) {
    let pivot = a[pivotIndex]
    var smaller = low
    var equal = low
    var larger = high
    while equal <= larger {
        if a[equal] < pivot {
            a.swapAt(smaller, equal)
            smaller += 1
            equal += 1
        } else if a[equal] == pivot {
            equal += 1
        } else {
            a.swapAt(equal, larger)
            larger -= 1
        }
    }
    return (smaller, larger)
}

public func quicksortDutchFlag<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let (middleFirst, middleLast) = partitionDutchFlag(&a, low: low, high: high, pivotIndex: high)
        quicksortDutchFlag(&a, low: low, high: middleFirst - 1)
        quicksortDutchFlag(&a, low: middleLast + 1, high: high)
    }
}
```

### Challenge 1

**Iteractive quicksort**

```swift
public func quicksortIterativeLomuto<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    var stack = Stack<Int>()
    stack.push(low)
    stack.push(high)
    
    while !stack.isEmpty {
        guard let end = stack.pop(),
              let start = stack.pop() else {
            continue
        }
        
        let p = partitionLomuto(&a, low: start, high: end)
        
        if (p - 1) > start {
            stack.push(start)
            stack.push(p - 1)
        }
        
        if (p + 1) < end {
            stack.push(p + 1)
            stack.push(end)
        }
    }
}
```



### Challenge 2

**Merge sort of quick sort**

 \- Merge sort is preferable over quick sort when you need stability. Merge sort is a stable sort and guarantees _O_(_n_ log _n_). This is not the case with quick sort, which isn’t stable and can perform as bad as _O_(_n²_).

 \- Merge sort works better for larger data structures or data structures where elements are scattered throughout memory. Quick sort works best when elements are stored in a contiguous block.

### Challenge 3

**Partitioning with Swift standard library**

```swift
extension MutableCollection where Self: BidirectionalCollection, Element: Comparable {
    
    mutating func quicksort() {
        partitionLomuto(low: startIndex, high: index(before: endIndex))
    }
    
    private mutating func partitionLomuto(low: Index, high: Index) {
        if low <= high {
            let pivotValue = self[high]
            var p = self.partition { $0 > pivotValue }
            
            if p == endIndex {
                p = index(before: p)
            }
            self[..<p].partitionLomuto(low: low, high: index(before: p))
            self[p...].partitionLomuto(low: index(after: p), high: high)
        }
    }
}
```