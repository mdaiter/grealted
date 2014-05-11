#ifndef graph_h
#define graph_h

#include "node.cuh"
#include "edge.cuh"

class Graph {
    public:
        Graph();
        Graph(std::vector<Node>, std::vector<Edge>);
        void addEdge(Edge);
        void addNode(Node);
        void removeEdge(int);
        void removeVector(int);
    private:
        std::vector<Node> nodes;
        std::vector<Edge> edges;
        AdjacencyMap map;
};

#endif
