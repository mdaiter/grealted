#include <cuda.h>
#include "../src/C/graph.cuh"

int main(){
    graph_t* graph = graph_load("graph1");
    node_t* new_node = node_init(0);
    graph_add_node(graph, new_node);
    edge_t* new_edge = edge_init_gpu(1, 0, 1);
    graph_add_edge(graph, new_edge);
    return 0;
}
