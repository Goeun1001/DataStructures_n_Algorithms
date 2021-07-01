import Foundation

extension Graph where Element: Hashable {
    func breadthFirstSearch(from source: Vertex<Element>) -> [Vertex<Element>] {
        var queue = QueueStack<Vertex<Element>>()
        var enqueued: Set<Vertex<Element>> = []
        var visited: [Vertex<Element>] = []
        
        queue.enqueue(source)
        enqueued.insert(source)
        
        while let vertex = queue.dequeue() {
            visited.append(vertex)
            let neighborEdges = edges(from: vertex)
            neighborEdges.forEach { edge in
                if !enqueued.contains(edge.destination) {
                    queue.enqueue(edge.destination)
                    enqueued.insert(edge.destination)
                }
            }
        }
        
        return visited
    }
}

// Challenge 2
// Iteractive BFS
extension Graph where Element: Hashable {
    func bfs(from source: Vertex<Element>) -> [Vertex<Element>] {
        var queue = QueueStack<Vertex<Element>>()
        var enqueued: Set<Vertex<Element>> = []
        var visited: [Vertex<Element>] = []
        
        queue.enqueue(source)
        enqueued.insert(source)
        
        bfs(queue: &queue, enqueued: &enqueued, visited: &visited)
        return visited
    }
    
    private func bfs(queue: inout QueueStack<Vertex<Element>>,
                     enqueued: inout Set<Vertex<Element>>,
                     visited: inout [Vertex<Element>]) {
        guard let vertex = queue.dequeue() else {
            return
        }
        visited.append(vertex)
        let neighborEdges = edges(from: vertex)
        neighborEdges.forEach { edge in
            if !enqueued.contains(edge.destination) {
                queue.enqueue(edge.destination)
                enqueued.insert(edge.destination)
            }
        }
        bfs(queue: &queue, enqueued: &enqueued, visited: &visited)
    }
}


// Challege 3
// Disconnected Graph
extension Graph where Element: Hashable {
    func isDisconnected() -> Bool {
        guard let firstVertex = allVertices.first else {
            return false
        }
        let visited = breadthFirstSearch(from: firstVertex)
        for vertex in allVertices {
            if !visited.contains(vertex) {
                return true
            }
        }
        return false
    }
}

extension Graph where Element: Hashable {
    func depthFirstSearch(from source: Vertex<Element>) -> [Vertex<Element>] {
        var stack: Stack<Vertex<Element>> = []
        var pushed: Set<Vertex<Element>> = []
        var visited: [Vertex<Element>] = []
        
        stack.push(source)
        pushed.insert(source)
        visited.append(source)
        
        outer: while let vertex = stack.peek() {
            let neighbors = edges(from: vertex)
            guard !neighbors.isEmpty else {
                stack.pop()
                continue
            }
            for edge in neighbors {
                if !pushed.contains(edge.destination) {
                    stack.push(edge.destination)
                    pushed.insert(edge.destination)
                    visited.append(edge.destination)
                    continue outer
                }
            }
            stack.pop()
        }
        return visited
    }
}

// Challege 2
// Recursive DFS
extension Graph where Element: Hashable {
    func depthFirstSearch2(from start: Vertex<Element>) -> [Vertex<Element>] {
        var visited: [Vertex<Element>] = [] // 1
        var pushed: Set<Vertex<Element>> = [] // 2
        depthFirstSearch(from: start, // 3
                         visited: &visited,
                         pushed: &pushed)
        return visited
    }
    
    func depthFirstSearch(from source: Vertex<Element>,
                          visited: inout [Vertex<Element>],
                          pushed: inout Set<Vertex<Element>>) {
        pushed.insert(source) // 1
        visited.append(source)
        
        let neighbors = edges(from: source)
        for edge in neighbors { // 2
            if !pushed.contains(edge.destination) {
                depthFirstSearch(from: edge.destination, // 3
                                 visited: &visited,
                                 pushed: &pushed)
            }
        }
    }
}

// Challege 3
// Detect a cycle
extension Graph where Element: Hashable {
    func hasCycle(from source: Vertex<Element>) -> Bool  {
        var pushed: Set<Vertex<Element>> = []
        return hasCycle(from: source, pushed: &pushed)
    }
    
    func hasCycle(from source: Vertex<Element>,
                  pushed: inout Set<Vertex<Element>>) -> Bool {
        pushed.insert(source)
        
        let neighbors = edges(from: source)
        for edge in neighbors {
            if !pushed.contains(edge.destination) &&
                hasCycle(from: edge.destination, pushed: &pushed) {
                return true
            } else if pushed.contains(edge.destination) {
                return true
            }
        }
        pushed.remove(source)
        return false
    }
}
