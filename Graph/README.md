# Graph

```swift
public struct Vertex<T> {
    public let index: Int
    public let data: T
}

extension Vertex: Hashable where T: Hashable {}
extension Vertex: Equatable where T: Equatable {}

extension Vertex: CustomStringConvertible {
    
    public var description: String {
        "\(index): \(data)"
    }
}

public struct Edge<T> {
    public let source: Vertex<T>
    public let destination: Vertex<T>
    public let weight: Double?
}

public enum EdgeType {
    case directed
    case undirected
}

public protocol Graph {
    associatedtype Element
    
    func createVertex(data: Element) -> Vertex<Element>
    func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?)
    func addUndirectedEdge(between source: Vertex<Element>, and destination: Vertex<Element>, weight: Double?)
    func add(_ edge: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?)
    func edges(from source: Vertex<Element>) -> [Edge<Element>]
    func weight(from source: Vertex<Element>, to destination: Vertex<Element>) -> Double?
}

extension Graph {
    public func addUndirectedEdge(between source: Vertex<Element>, and destination: Vertex<Element>, weight: Double?) {
        addDirectedEdge(from: source, to: destination, weight: weight)
        addDirectedEdge(from: destination, to: source, weight: weight)
    }
    
    public func add(_ edge: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) {
        switch edge {
        case .directed:
            addDirectedEdge(from: source, to: destination, weight: weight)
        case .undirected:
            addUndirectedEdge(between: source, and: destination, weight: weight)
        }
    }
}
```

## AdjacencyList

```swift
public class AdjacencyList<T: Hashable>: Graph {
    private var adjacencies: [Vertex<T>: [Edge<T>]] = [:]
    
    public init() {}
    
    public func createVertex(data: T) -> Vertex<T> {
        let vertex = Vertex(index: adjacencies.count, data: data)
        adjacencies[vertex] = []
        return vertex
    }
    
    public func addDirectedEdge(from source: Vertex<T>, to destination: Vertex<T>, weight: Double?) {
        let edge = Edge(source: source, destination: destination, weight: weight)
        adjacencies[source]?.append(edge)
    }
    
    public func edges(from source: Vertex<T>) -> [Edge<T>] {
        adjacencies[source] ?? []
    }
    
    public func weight(from source: Vertex<T>, to destination: Vertex<T>) -> Double? {
        edges(from: source).first { $0.destination == destination }?.weight
    }
}

extension AdjacencyList: CustomStringConvertible {
    public var description: String {
        var result = ""
        for (vertex, edges) in adjacencies {
            var edgeString = ""
            for (index, edge) in edges.enumerated() {
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ]\n")
        }
        return result
    }
}
```

## AdjacencyMatrix

```swift
public class AdjacencyMatrix<T>: Graph {
    private var vertices: [Vertex<T>] = []
    private var weights: [[Double?]] = []
    
    public init() {}
    
    public func createVertex(data: T) -> Vertex<T> {
        let vertex = Vertex(index: vertices.count, data: data)
        vertices.append(vertex)
        for i in 0..<weights.count {
            weights[i].append(nil)
        }
        let row = [Double?](repeating: nil, count: vertices.count)
        weights.append(row)
        return vertex
    }
    
    public func addDirectedEdge(from source: Vertex<T>, to destination: Vertex<T>, weight: Double?) {
        weights[source.index][destination.index] = weight
    }
    
    public func edges(from source: Vertex<T>) -> [Edge<T>] {
        var edges: [Edge<T>] = []
        for column in 0..<weights.count {
            if let weight = weights[source.index][column] {
                edges.append(Edge(source: source, destination: vertices[column], weight: weight))
            }
        }
        return edges
    }
    
    public func weight(from source: Vertex<T>, to destination: Vertex<T>) -> Double? {
        weights[source.index][destination.index]
    }
}

extension AdjacencyMatrix: CustomStringConvertible {
    public var description: String {
        // 1
        let verticesDescription = vertices.map { "\($0)" }.joined(separator: "\n")
        // 2
        var grid: [String] = []
        for i in 0..<weights.count {
            var row = ""
            for j in 0..<weights.count {
                if let value = weights[i][j] {
                    row += "\(value)\t"
                } else {
                    row += "ø\t\t"
                }
            }
            grid.append(row)
        }
        let edgesDescription = grid.joined(separator: "\n")
        // 3
        return "\(verticesDescription)\n\n\(edgesDescription)"
    }
}
```

## Challenge 1

**Couunt the number of paths**

```swift

extension Graph where Element: Hashable {
    
    public func numberOfPaths(from source: Vertex<Element>, to destination: Vertex<Element>) -> Int {
        var numberOfPaths = 0
        var visited: Set<Vertex<Element>> = []
        paths(from: source, to: destination, visited: &visited, pathCount: &numberOfPaths)
        return numberOfPaths
    }
    
    func paths(from source: Vertex<Element>,
               to destination: Vertex<Element>,
               visited: inout Set<Vertex<Element>>,
               pathCount: inout Int) {
        visited.insert(source)
        if source == destination {
            pathCount += 1
        } else {
            let neighbors = edges(from: source)
            for edge in neighbors {
                if !visited.contains(edge.destination) {
                    paths(from: edge.destination, to: destination, visited: &visited, pathCount: &pathCount)
                }
            }
        }
        // Remove the vertex from the visited list, so you can find other paths to that node.
        visited.remove(source)
    }
}
```

## Challenge 2

**Graph your friends**

```swift
let graph = AdjacencyList<String>()

let vincent = graph.createVertex(data: "vincent")
let chesley = graph.createVertex(data: "chesley")
let ruiz = graph.createVertex(data: "ruiz")
let patrick = graph.createVertex(data: "patrick")
let ray = graph.createVertex(data: "ray")
let sun = graph.createVertex(data: "sun")
let cole = graph.createVertex(data: "cole")
let kerry = graph.createVertex(data: "kerry")

graph.add(.undirected, from: vincent, to: chesley, weight: 1)
graph.add(.undirected, from: vincent, to: ruiz, weight: 1)
graph.add(.undirected, from: vincent, to: patrick, weight: 1)
graph.add(.undirected, from: ruiz, to: ray, weight: 1)
graph.add(.undirected, from: ruiz, to: sun, weight: 1)
graph.add(.undirected, from: patrick, to: cole, weight: 1)
graph.add(.undirected, from: patrick, to: kerry, weight: 1)
graph.add(.undirected, from: cole, to: ruiz, weight: 1)
graph.add(.undirected, from: cole, to: vincent, weight: 1)

print(graph)

print("Ruiz and Vincent both share a friend name Cole")

let vincentsFriends = Set(graph.edges(from: vincent).map { $0.destination.data })
let mutual = vincentsFriends.intersection(graph.edges(from: ruiz).map { $0.destination.data })
print(mutual)
```

# BFS

![img](https://blog.kakaocdn.net/dn/c305k7/btqB5E2hI4r/ea7vFo08tkDYo4c8wkfVok/img.gif)

```swift
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
```

## Challenge 2

**Iteractive BFS**

```swift
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
```

## Challege 3

**Disconnected Graph**

```swift
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
```

# DFS

![img](https://blog.kakaocdn.net/dn/xC9Vq/btqB8n5A25K/GyOf4iwqu8euOyhwtFuyj1/img.gif)

```swift
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
```

## Challege 2

**Recursive DFS**

```swift
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
```

## Challege 3

**Detect a cycle**

```swift
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
```

# Dijkstra Algorithm

```swift
public enum Visit<T: Hashable> {
    case start
    case edge(Edge<T>)
}

public class Dijkstra<T: Hashable> {
    public typealias Graph = AdjacencyList<T>
    let graph: Graph
    
    public init(graph: Graph) {
        self.graph = graph
    }
    
    private func route(to destination: Vertex<T>, with paths: [Vertex<T> : Visit<T>]) -> [Edge<T>] {
        var vertex = destination
        var path: [Edge<T>] = []
        
        while let visit = paths[vertex], case .edge(let edge) = visit {
            path = [edge] + path
            vertex = edge.source
        }
        return path
    }
    
    private func distance(to destination: Vertex<T>, with paths: [Vertex<T> : Visit<T>]) -> Double {
        let path = route(to: destination, with: paths)
        let distances = path.compactMap { $0.weight }
        return distances.reduce(0.0, +)
    }
    
    public func shortestPath(from start: Vertex<T>) -> [Vertex<T> : Visit<T>] {
        var paths: [Vertex<T> : Visit<T>] = [start: .start]
        
        var priorityQueue = PriorityQueue<Vertex<T>>(sort: {
            self.distance(to: $0, with: paths) < self.distance(to: $1, with: paths)
        })
        priorityQueue.enqueue(start)
        
        while let vertex = priorityQueue.dequeue() {
            for edge in graph.edges(from: vertex) {
                guard let weight = edge.weight else {
                    continue
                }
                if paths[edge.destination] == nil || distance(to: vertex, with: paths) + weight < distance(to: edge.destination, with: paths) {
                    print(edge.destination)
                    paths[edge.destination] = .edge(edge)
                    priorityQueue.enqueue(edge.destination)
                }
            }
        }
        
        return paths
    }
    
    public func shortestPath(to destination: Vertex<T>, paths: [Vertex<T> : Visit<T>]) -> [Edge<T>] {
        route(to: destination, with: paths)
    }
}
```

## Challenge 2

**Find all the shortest paths**

```swift
extension Dijkstra {
    public func getAllShortestPath(from source: Vertex<T>) -> [Vertex<T> : [Edge<T>]] {
        var pathsDict = [Vertex<T> : [Edge<T>]]()
        let pathsFromSource = shortestPath(from: source)
        for vertex in graph.allVertices {
            let path = shortestPath(to: vertex, paths: pathsFromSource)
            pathsDict[vertex] = path
        }
        return pathsDict
    }
}
```

# Prims

```swift
public class Prim<T: Hashable> {
    public typealias Graph = AdjacencyList<T>
    public init() {}
    
    public func produceMinimumSpanningTree(for graph: Graph) -> (cost: Double, mst: Graph) {
        var cost = 0.0
        let mst = Graph()
        var visited: Set<Vertex<T>> = []
        var priorityQueue = PriorityQueue<Edge<T>>(sort: {
            $0.weight ?? 0.0 < $1.weight ?? 0.0
        })
        
        mst.copyVertices(from: graph)
        
        guard let start = graph.allVertices.first else {
            return (cost: cost, mst: mst)
        }
        
        visited.insert(start)
        addAvailableEdges(for: start, in: graph, check: visited, to: &priorityQueue)
        
        while let smallestEdge = priorityQueue.dequeue() {
            let vertex = smallestEdge.destination
            
            guard !visited.contains(vertex) else {
                continue
            }
            
            visited.insert(vertex)
            cost += smallestEdge.weight ?? 0.0
            mst.add(.undirected, from: smallestEdge.source, to: smallestEdge.destination, weight: smallestEdge.weight)
            
            addAvailableEdges(for: vertex, in: graph, check: visited, to: &priorityQueue)
        }
        
        return (cost: cost, mst: mst)
    }
    
    internal func addAvailableEdges(for vertex: Vertex<T>,
                                    in graph: Graph,
                                    check visited: Set<Vertex<T>>,
                                    to priorityQueue: inout PriorityQueue<Edge<T>>) {
        for edge in graph.edges(from: vertex) {
            if !visited.contains(edge.destination) {
                priorityQueue.enqueue(edge)
            }
        }
    }
}
```

## Challenge 1

**Miniumum spanning tree of points**

```swift
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGPoint {
    func distanceSquared(to point: CGPoint) -> CGFloat {
        let xDistance = (x - point.x)
        let yDistance = (y - point.y)
        return xDistance * xDistance + yDistance * yDistance
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        distanceSquared(to: point).squareRoot()
    }
}

extension Prim where T == CGPoint {
    public func createCompleteGraph(with points: [CGPoint]) -> Graph {
        let completeGraph = Graph()
        
        // Convert the set of points to vertices
        points.forEach { point in
            completeGraph.createVertex(data: point)
        }
        
        // Create an edge between every vertex, and calculate the distance (weight)
        // from point to point.
        completeGraph.allVertices.forEach { currentVertex in
            completeGraph.allVertices.forEach { vertex in
                if currentVertex != vertex {
                    let distance = Double(currentVertex.data.distance(to: vertex.data))
                    completeGraph.addDirectedEdge(from: currentVertex, to: vertex, weight: distance)
                }
            }
        }
        
        return completeGraph
    }
    
    public func produceMinimumSpanningTree(with points: [CGPoint]) -> (cost: Double, mst: Graph) {
        let completeGraph = createCompleteGraph(with: points)
        return produceMinimumSpanningTree(for: completeGraph)
    }
}
```

