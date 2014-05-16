#include "graph.cuh"
#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "redis_client.h"
#include "../../hiredis/hiredis.h"
#include "node.h"
#include "edge.h"

#ifdef __cplusplus
}
#endif

int string_length(char *s)
{
    int c = 0;
        
    while(*(s+c))
        c++;
           
    return c;
}

void graph_init(graph_t* graph, char* name){
    graph = (graph_t*) malloc(sizeof(graph_t));
    kv_init(graph->nodes);
    kv_init(graph->edges);
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
    graph_t* graph = (graph_t*) malloc(sizeof(graph_t));
    //Then we deal with the interior nodes
    kv_init(graph->nodes);
    kv_init(graph->edges);
    graph->adjacency_map = (adjacency_map*) malloc(sizeof(adjacency_map));

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
        node_t* node = node_init(i);
        node_load(node, graph->redis_context, graph->name);
        kv_push(node_t*, graph->nodes, node);
    }
    
    //Get the edges from the database
    #pragma omp parallel for ordered schedule(dynamic)
    for (int i = 0; i < edge_size; i++){
        edge_t* edge = edge_init(i, -1, -1);
        edge_load(edge, graph->redis_context, graph->name);
        kv_push(edge_t*, graph->edges, edge);
    }
    return graph;
}

void graph_add_node(graph_t* graph, node_t* node){
    node_save(node, graph->redis_context, graph->name);
    //Take care of database stuff. Then add to graph
    redisReply* reply;
    reply = (redisReply*)redisCommand(graph->redis_context, "INCR %s:nodes:size", graph->name);
    freeReplyObject(reply);

    //Now add to graph
    kv_push(node_t*, graph->nodes, node);
}

void graph_add_edge(graph_t* graph, edge_t* edge){
    edge_save(edge, graph->redis_context, graph->name);
    redisReply* reply;
    reply = (redisReply*)redisCommand(graph->redis_context, "INCR %s:edges:size", graph->name);
    freeReplyObject(reply);

    kv_push(edge_t*, graph->edges, edge);
}

void graph_add_edge_between_nodes(graph_t* graph, edge_t* edge, node_t* n_start, node_t* n_end){
    edge->n_start = n_start->id;
    edge->n_end = n_end->id;
    graph_add_edge(graph, edge);
}

__global__ void graph_find(node_t* nodes, char* key, void* value, node_t* d_node_out){
    __shared__ int d_node_out_size;
    
    int i = threadIdx.x + blockIdx.x * blockDim.x;


    any_t holder = malloc(sizeof(*any_t));

    hashmap_get(nodes[i].attr, key, holder);

    if ( holder == value ){
        d_node_out[d_node_out_size] = nodes[i];
        atomicAdd(d_node_out_size);
        d_node_out = (node_t*) realloc(d_node_out, (d_node_out_size + 1) * sizeof(node_t));
    }
}

node_t* graph_find_V(graph_t* graph, char* key, any_t value){
    node_t* h_nodes = (node_t*)graph->nodes->a;

    node_t* d_nodes;
    char* d_key;
    any_t d_value;

    cudaMalloc((void**)&d_nodes, kv_size(graph->nodes) * sizeof(node_t));
    cudaMalloc((void**)&key, string_length(key) * sizeof(char));
    cudaMalloc((void**)&value, sizeof(any_t));
    
    cudaMemcpy(d_nodes, h_nodes, kv_size(graph->nodes) * sizeof(node_t), cudaMemcpyHostToDevice);
    cudaMemcpy(d_key, key, string_length(key) * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_value, value, sizeof(any_t), cudaMemcpyHostToDevice);

    graph_find<<<1, 1024>>>(d_nodes, key, value);


}
