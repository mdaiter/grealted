#include "graph.cuh"
#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "../C/redis_client.h"
#include "../../hiredis/hiredis.h"
#include "../C/node.h"
#include "../C/edge.h"

#ifdef __cplusplus
}
#endif

#include "node.cuh"
#include "edge.cuh"

int string_length(char *s)
{
    int c = 0;
        
    while(*(s+c))
        c++;
           
    return c;
}

void graph_init(graph_t* graph, char* name){
    graph = (graph_t*) malloc(sizeof(graph_t));
    graph->nodes = node_vector_init(0);
    graph->edges = edge_vector_init(0);
    graph->adjacency_map = (adjacency_map*) malloc(sizeof(adjacency_map));

    graph->name = (char*) malloc(string_length(name) * sizeof(char));

    graph->redis_context = redisConnect("127.0.0.1", 6379);

    if (graph->redis_context != NULL && graph->redis_context->err){
        printf("Error initializing redis: %s\n", graph->redis_context->err);
    }
    
    redis_client_set_node_size(graph->redis_context, graph->name, 0);
    redis_client_set_edge_size(graph->redis_context, graph->name, 0);
}

graph_t* graph_load(char* name){
    //First we handle making the actual object
    graph_t* graph;
    cudaMallocManaged(&graph, sizeof(graph_t));
    //Then we deal with the interior nodes
    graph->nodes = node_vector_init(0);
    graph->edges = edge_vector_init(0);

    graph->name = (char*) malloc(string_length(name) * sizeof(char));
    graph->name = name;

    //Initialize context to server
    graph->redis_context = redisConnect("127.0.0.1", 6379);

    if (graph->redis_context != NULL && graph->redis_context->err){
        printf("Error initializing redis: %s\n", graph->redis_context->err);
    }

    int node_size =  redis_client_get_node_size(graph->redis_context, graph->name);
    int edge_size = redis_client_get_edge_size(graph->redis_context, graph->name);

    //Get the nodes from the database
    #pragma omp parallel for ordered schedule(dynamic)
    for (int i = 0; i < node_size; i++){
        node_t* node = node_init_gpu(i);
        node_load(node, graph->redis_context, graph->name);
        node_vector_add(graph->nodes, node);
    }
    
    //Get the edges from the database
    #pragma omp parallel for ordered schedule(dynamic)
    for (int i = 0; i < edge_size; i++){
        edge_t* edge = edge_init_gpu(i, -1, -1);
        edge_load(edge, graph->redis_context, graph->name);
        edge_vector_add(graph->edges, edge);
    }

    graph->adjacency_map = adjacency_map_init(node_size, graph->edges->stuff, edge_size);
    return graph;
}

void graph_add_node(graph_t* graph, node_t* node){
    node_save(node, graph->redis_context, graph->name);
    //Take care of database stuff. Then add to graph
    redisReply* reply;
    reply = (redisReply*)redisCommand(graph->redis_context, "INCR %s:nodes:size", graph->name);
    freeReplyObject(reply);

    //Now add to graph
    node_vector_add(graph->nodes, node);
}

void graph_add_edge(graph_t* graph, edge_t* edge){
    edge_save(edge, graph->redis_context, graph->name);
    redisReply* reply;
    reply = (redisReply*)redisCommand(graph->redis_context, "INCR %s:edges:size", graph->name);
    freeReplyObject(reply);

    edge_vector_add(graph->edges, edge);
}

void graph_add_edge_between_nodes(graph_t* graph, edge_t* edge, node_t* n_start, node_t* n_end){
    edge->n_start = n_start->id;
    edge->n_end = n_end->id;
    graph_add_edge(graph, edge);
}

__global__ void graph_find(node_vector_t* nodes, char* key, char* value, node_t* d_node_out){
    __shared__ node_vector_t* return_vector;
    
    int i = threadIdx.x + blockIdx.x * blockDim.x;

    hashmap_get(nodes[i].attr, key, holder);

    if ( holder != NULL && holder == value ){
        d_node_out[d_node_out_size] = nodes[i];
        atomicAdd(d_node_out_size);
        d_node_out = (node_t*) realloc(d_node_out, (d_node_out_size + 1) * sizeof(node_t));
    }
}

node_t* graph_find_V(graph_t* graph, char* key, char* value){

    char* d_key;
    
    cudaMalloc((void**)&key, string_length(key) * sizeof(char));
    
    cudaMemcpy(d_key, key, string_length(key) * sizeof(char), cudaMemcpyHostToDevice);
    node_vector_t* d_node_out = node_vector_init(0);
    graph_find<<<1, 1024>>>(graph->nodes, key, value, d_node_out);

    cudaFree(d_key);
}
