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

// Challenge 1
// Miniumum spanning tree of points

import UIKit

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

// Interested in trying out other points?
func generateRandomPoints(count: Int, range: Range<CGFloat>) -> [CGPoint] {
    (1...count).map { _ in
        CGPoint(x: CGFloat.random(in: range), y: CGFloat.random(in: range))
    }
}

// You can plot your points using the following:
// Copy and paste the follow points into `desmos`
// (4.0, 0.0), (6.0, 16.0), (10.0, 1.0), (3.0, 17.0), (18.0, 7.0), (5.0, 14.0)
//https://www.desmos.com/calculator

let points = [CGPoint(x: 4, y: 0), // 0
              CGPoint(x: 6, y: 16), // 1
              CGPoint(x: 10, y: 1), // 2
              CGPoint(x: 3, y: 17), // 3
              CGPoint(x: 18, y: 7), // 4
              CGPoint(x: 5, y: 14)] // 5

let (cost,mst) = Prim().produceMinimumSpanningTree(with: points)

print(mst)
print(cost)
