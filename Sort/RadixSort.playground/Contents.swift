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

// Challenge 1
// Most singificant digit
import Foundation

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
        self = lsdRadixSorted(self, 0)
    }
    
    private func lsdRadixSorted(_ array: [Int], _ position: Int) -> [Int] {
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
            result.append(contentsOf: lsdRadixSorted(bucket, position + 1))
        })
        return priorityBucket
    }
}

var array = [500, 1345, 13, 459, 44, 999]
array.lexicographicalSort()
print(array) // outputs [13, 1345, 44, 459, 500, 999]

var array2: [Int] = (0...10).map { _ in Int.random(in: 1...100000) }
array2.lexicographicalSort()
print(array2)

