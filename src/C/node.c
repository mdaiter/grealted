#include "node.h"
#include <stdlib.h>
#include "../../hiredis/hiredis.h"
void node_init(node_t* node, int _id){
    node = (node_t*) malloc(sizeof(node_t));
    node->id = _id;
    node->attr = hashmap_new();
    kv_init(node->edges);
}

void node_add_attr(node_t* node, char* key, any_t val){
    hashmap_put(node->attr, key, val);
}

void node_remove_attr(node_t* node, char* key){
    hashmap_remove(node->attr, key);
}

void node_set_id(node_t* node, int _id){
    node->id = _id;
}

//Warning: only applies for starting edge: reduces data consumption
void node_add_edge(node_t* node, int edgeNum){
    kv_push(int, node->edges, edgeNum);
}

void node_remove_edge(node_t* node, int edgeNum){

}

void node_destroy(node_t* node){
    //remove interior stuff first
    kv_destroy(node->edges);
    hashmap_free(node->attr);

    free(node);
}

void node_load(node_t* node, redisContext* context){
    redisReply* reply;
    reply = redisCommand(context, "GET nodes:node%d", node->id);
    //Parse string stuff here
}
