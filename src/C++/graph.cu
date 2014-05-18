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

#include "hash.cuh"
#include "node.cuh"
#include "edge.cuh"
__device__ __host__ int strlen(char* s){
	int c = 0;
	while(*(s+c)){
		c++;
	}
	return c;
}

__device__ __host__ int strcmp(char* str1, char* str2){
	if (str1 == NULL || str2 == NULL){
		return -1;
	}
	char* i = str1;
	char* j = str2;
	int i_len = strlen(str1);
	int j_len = strlen(str2);
	if (i_len != j_len){
		return -1;
	}
	
	for(int x = 0;  x < i_len && x < j_len; x++){
		if ((int)i[x] > (int)j[x]){
			return 1;
		}
		else if ((int)i[x] < (int)j[x]){
			return -1;
		}
		//i++;
		//j++;
	}
	return 0;
}

/* Hash a string for a particular hash table. */
__device__ __host__ int ht_hash( hashtable_t *hashtable, char *key ) {

	unsigned long int hashval;
	int i = 0;

	/* Convert our string to an integer */
	while( hashval < ULONG_MAX && i < strlen( key ) ) {
		hashval = hashval << 8;
		hashval += key[ i ];
		i++;
	}

	return hashval % hashtable->size;
}

/* Retrieve a key-value pair from a hash table. */
__device__ __host__ char *ht_get( hashtable_t *hashtable, char *key ) {
	int bin = 0;
	entry_t *pair;

	bin = ht_hash( hashtable, key );

	/* Step through the bin, looking for our value. */
	pair = hashtable->table[ bin ];
	while( pair != NULL && pair->key != NULL && strcmp( key, pair->key ) > 0 ) {
		pair = pair->next;
	}

	/* Did we actually find anything? */
	if( pair == NULL || pair->key == NULL || strcmp( key, pair->key ) != 0 ) {
		return NULL;

	} else {
		return pair->value;
	}
	
}
void graph_init(graph_t* graph, char* name){
    graph = (graph_t*) malloc(sizeof(graph_t));
    graph->nodes = node_vector_init(0);
    graph->edges = edge_vector_init(0);
    graph->adjacency_map = (adjacency_map*) malloc(sizeof(adjacency_map));

    graph->name = (char*) malloc(strlen(name) * sizeof(char));

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

    graph->name = (char*) malloc(strlen(name) * sizeof(char));
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
        //node_t* node = node_init_gpu(i);
        //node_load(node, graph->redis_context, graph->name);
        //node_vector_add(graph->nodes, node);
    }
    
    //Get the edges from the database
    #pragma omp parallel for ordered schedule(dynamic)
    for (int i = 0; i < edge_size; i++){
        //edge_t* edge = edge_init_gpu(i, -1, -1);
        //edge_load(edge, graph->redis_context, graph->name);
        //edge_vector_add(graph->edges, edge);
    }

    //graph->adjacency_map = adjacency_map_init(node_size, graph->edges->stuff, edge_size);
    return graph;
}

void graph_add_node(graph_t* graph, node_t* node){
    //node_save(node, graph->redis_context, graph->name);
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

__global__ void graph_find(node_vector_t* nodes, char* key, char* value, node_vector_t* d_node_out){
    
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    max(i, 0);
    min(i, nodes->size);

    node_t* local_node = nodes->stuff[i];
    char* holder = ht_get(local_node->attr, key);

    if ( holder != NULL && holder == value ){
	node_t** vec2 = (node_t**)malloc(sizeof(node_t*) * (nodes->size + 1));
	memcpy(vec2, nodes->stuff, sizeof(node_t*) * (nodes->size));
	free(nodes->stuff);
	nodes->stuff = vec2;
	nodes->size++;
	nodes->stuff[nodes->size - 1] = local_node;
    }
}

node_vector_t* graph_find_V(graph_t* graph, char* key, char* value){

    char* d_key;
    
    cudaMalloc((void**)&d_key, strlen(key) * sizeof(char));
    
    cudaMemcpy(d_key, key, strlen(key) * sizeof(char), cudaMemcpyHostToDevice);
    node_vector_t* d_node_out = node_vector_init(0);
    graph_find<<<1, 1024>>>(graph->nodes, key, value, d_node_out);

    cudaFree(d_key);
    return d_node_out;
}
