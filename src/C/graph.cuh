#ifndef graph_cuh
#define graph_cuh

extern "C"{
#include "node.h"
#include "edge.h"
#include "adjacency_map.cuh"
#include "kvec.h"
}
typedef struct graph_t {
    kvec_t(node_t*) nodes;
    kvec_t(edge_t*) edges;
    adjacency_map *adjacency_map;
    char* name;
    redisContext *redis_context;
} graph_t;

void graph_init(graph_t*, char*);

graph_t* graph_load(char*);

void graph_add_node(graph_t*, node_t*);

void graph_add_edge(graph_t*, edge_t*);

__global__ void graph_find(node_t*, char*, void*, node_t*);

#endif
