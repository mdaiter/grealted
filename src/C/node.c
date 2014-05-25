#include "node.h"
#include <stdlib.h>
#include <stdio.h>
#include "../../hiredis/hiredis.h"
#include <errno.h>
#include "../C++/hash.cuh"

node_t* node_init(int _id){
    node_t* node = (node_t*) malloc(sizeof(node_t));
    node->id = _id;
    node->attr = ht_create(1);
    ht_set(node->attr, "", "");
    kv_init(node->edges);
    node->is_selected = true;
    return node;
}

void node_add_attr(node_t* node, char* key, char* val){
    ht_set(node->attr, key, val);
}

char* node_get_attr(node_t* node, char* key){
    return ht_get(node->attr, key);
}

void node_remove_attr(node_t* node, char* key){
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
    free(node->attr);

    free(node);
}

void node_load(node_t* node, redisContext* context, char* name){
    redisReply* reply;
    //Get map of attributes
    reply = redisCommand(context, "HGETALL %s:nodes:node%d:attr", name, node->id);
    int i = 0;
    for (; i < reply->elements; i = i + 2){
        printf("Received object: %s from %d\n", reply->element[i]->str, i);
        //1 means string; 3 means integer returned
        if (reply->element[i+1]->type == 1){
            ht_set(node->attr, reply->element[i]->str, reply->element[i+1]->str);
        }
        else if (reply->element[i+1]->type == 3){
            ht_set(node->attr, reply->element[i]->str, reply->element[i+1]->str);
        }
    }
    freeReplyObject(reply);
    //Get vector of edges
    reply = redisCommand(context, "LRANGE %s:nodes:node%d:edges 0 -1");
    i = 0;
    for (; i < reply->elements; i++){
        kv_push(int, node->edges, reply->element[i]->integer);
    }
    freeReplyObject(reply);
}

void node_save(node_t* node, redisContext* context, char* name){
    redisReply* reply;
    int i = 0;
    //Deal with maps first; get to vector later
    for (; i < node->attr->entry_size; i++){
        //Check if string or number
        char* temp_string = node->attr->table[i]->value;
        char* p = temp_string;
        //This is defined in errno.h. Basically, you're modifing it in an isolated enviornment to see changes
        errno = 0;
        unsigned long val = strtoul(temp_string, &p, 10);
        //If this fails, it's a string; else, it's an int
        if (errno != 0 || temp_string == p || *p != 0){
            reply = redisCommand(context, "HSET %s:nodes:node%d:attr %s %s", name, node->id, node->attr->table[i]->key, node->attr->table[i]->value);
        }
        else{
            reply = redisCommand(context, "HSET %s:nodes:node%d:attr %s %llu", name, node->id, node->attr->table[i]->key, node->attr->table[i]->value);
        }
        freeReplyObject(reply);
    }
    i = 0;
    //Now deal with the vector
    for (; i < kv_size(node->edges); i++){
        reply = redisCommand(context, "LSET %s:nodes:node%d:edges %d %s", name, node->id, i, kv_pop(node->edges));
        freeReplyObject(reply);
    }

}
