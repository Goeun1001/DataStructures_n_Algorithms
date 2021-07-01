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

let graph = AdjacencyList<String>()

let a = graph.createVertex(data: "A")
let b = graph.createVertex(data: "B")
let c = graph.createVertex(data: "C")
let d = graph.createVertex(data: "D")
let e = graph.createVertex(data: "E")
let f = graph.createVertex(data: "F")
let g = graph.createVertex(data: "G")
let h = graph.createVertex(data: "H")

graph.add(.directed, from: a, to: b, weight: 8)
graph.add(.directed, from: a, to: f, weight: 9)
graph.add(.directed, from: a, to: g, weight: 1)
graph.add(.directed, from: b, to: f, weight: 3)
graph.add(.directed, from: b, to: e, weight: 1)
graph.add(.directed, from: f, to: a, weight: 2)
graph.add(.directed, from: h, to: f, weight: 2)
graph.add(.directed, from: h, to: g, weight: 5)
graph.add(.directed, from: g, to: c, weight: 3)
graph.add(.directed, from: c, to: e, weight: 1)
graph.add(.directed, from: c, to: b, weight: 3)
graph.add(.undirected, from: e, to: c, weight: 8)
graph.add(.directed, from: e, to: b, weight: 1)
graph.add(.directed, from: e, to: d, weight: 2)

let dijkstra = Dijkstra(graph: graph)
let pathsFromA = dijkstra.shortestPath(from: a)
let path = dijkstra.shortestPath(to: d, paths: pathsFromA)

for edge in path {
    print("\(edge.source) --|\(edge.weight ?? 0.0)|--> \(edge.destination)")
}


// Challenge 2
// Find all the shortest paths
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
