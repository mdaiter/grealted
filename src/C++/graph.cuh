#ifndef graph_cuh
#define graph_cuh

//Include CUDA stuff first (C++ compiled)
#include "adjacency_map_single.cuh"

#ifdef __cplusplus
extern "C"{
#endif
#include "../C/node.h"
#include "../C/edge.h"
#ifdef __cplusplus
}
#endif

//We need vectors to hold the nodes and edges...
#include "node_vector.cuh"
#include "edge_vector.cuh"

typedef struct graph_t {
    node_vector_t* nodes;
    edge_vector_t* edges;
    adjacency_map *adjacency_map;
    char* name;
    redisContext *redis_context;
} graph_t;

void graph_init(graph_t*, char*);

graph_t* graph_load(char*);

void graph_add_node(graph_t*, node_t*);

void graph_add_edge(graph_t*, edge_t*);

__global__ void graph_find(node_t*, char*, void*, node_t*);

void graph_find_V(graph_t*, char*, char*);

#endif
