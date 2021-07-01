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

public class AdjacencyMatrix<T>: Graph {
    private var vertices: [Vertex<T>] = []
    private var weights: [[Double?]] = []
    
    public init() {}
    
    public func createVertex(data: T) -> Vertex<T> {
        let vertex = Vertex(index: vertices.count, data: data)
        vertices.append(vertex)
        for i in 0..<weights.count {
            weights[i].append(nil) // 세로 00000
        }
        let row = [Double?](repeating: nil, count: vertices.count) // 가로 00000
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

// Challenge 1
// Couunt the number of paths
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


// Challenge 2
// Graph your friends
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

