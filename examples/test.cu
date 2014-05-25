#include <cuda.h>
#include "../src/C++/graph.cuh"
#include "../src/C++/edge.cuh"
#include "../src/C++/node.cuh"
#include "../src/C++/node_vector.cuh"
#include <stdio.h>

int main(){
    graph_t* graph = graph_load("graph1");
    node_t* new_node = node_init_gpu(0);
    node_add_attr(new_node, "name", "Matt");
    node_t* new_node2 = node_init_gpu(1);
    node_t* new_node3 = node_init_gpu(2);
    node_add_attr(new_node2, "name", "Lisa");
    node_add_attr(new_node3, "name", "Eric");
    graph_add_node(graph, new_node);
    graph_add_node(graph, new_node2);
    graph_add_node(graph, new_node3);
    edge_t* new_edge = edge_init_gpu(1, 0, 1);
    graph_add_edge(graph, new_edge);
    
    graph_find_V(graph, "name", "Matt");
    for(int i = 0; i < graph->nodes->size; i++){
	char* temp_name = node_get_attr(graph->nodes->stuff[i], "name");
	printf("%d is the id of %s\n", graph->nodes->stuff[i]->id, temp_name);
    }
    return 0;
}
