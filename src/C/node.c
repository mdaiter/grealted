#include "node.h"
#include <stdlib.h>
#include <stdio.h>
#include "../../hiredis/hiredis.h"
#include <errno.h>

node_t* node_init(int _id){
    node_t* node = (node_t*) malloc(sizeof(node_t));
    node->id = _id;
    node->attr = hashmap_new();
    kv_init(node->edges);
    return node;
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

void node_load(node_t* node, redisContext* context, char* name){
    redisReply* reply;
    //Get map of attributes
    reply = redisCommand(context, "HGETALL %s:nodes:node%d:attr", name, node->id);
    int i = 0;
    for (; i < reply->elements; i = i + 2){
        printf("Received object: %s from %d\n", reply->element[i]->str, i);
        //1 means string; 3 means integer returned
        if (reply->element[i+1]->type == 1){
            hashmap_put(node->attr, reply->element[i]->str, reply->element[i+1]->str);
        }
        else if (reply->element[i+1]->type == 3){
            hashmap_put(node->attr, reply->element[i]->str, reply->element[i+1]->integer);
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
    hashmap_map* m = (hashmap_map*) node->attr;
    //Deal with maps first; get to vector later
    for (; i < hashmap_length(node->attr); i++){
        //Check if string or number
        char* temp_string = m->data[i].data;
        char* p = temp_string;
        //This is defined in errno.h. Basically, you're modifing it in an isolated enviornment to see changes
        errno = 0;
        unsigned long val = strtoul(temp_string, &p, 10);
        //If this fails, it's a string; else, it's an int
        if (errno != 0 || temp_string == p || *p != 0){
            reply = redisCommand(context, "HSET %s:nodes:node%d:attr %s %s", name, node->id, m->data[i].key, m->data[i].data);
        }
        else{
            reply = redisCommand(context, "HSET %s:nodes:node%d:attr %s %llu", name, node->id, m->data[i].key, m->data[i].data);
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
