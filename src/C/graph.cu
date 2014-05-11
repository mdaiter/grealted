#include "graph.cuh"
#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

extern "C" {
#include "redis_client.h"
#include "../../hiredis/hiredis.h"
#include "node.h"
#include "edge.h"
}

int string_length(char *s)
{
    int c = 0;
        
    while(*(s+c))
        c++;
           
    return c;
}

void graph_init(graph_t* graph, char* name){
    //First we handle making the actual object
    graph = (graph_t*) malloc(sizeof(graph_t));
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
        node_t* node;
        node_init(node, -1);
        node_load(node, graph->redis_context);
        kv_push(node_t*, graph->nodes, node);
    }
    
    //Get the edges from the database
    #pragma omp parallel for ordered schedule(dynamic)
    for (int i = 0; i < edge_size; i++){
        
    }
}


