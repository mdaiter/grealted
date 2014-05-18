#include "edge.h"
#include <stdlib.h>

edge_t* edge_init(int _id, int _n_start, int _n_end){
    edge_t* e = (edge_t*) malloc(sizeof(edge_t));
    e->id = _id;
    e->n_start = _n_start;
    e->n_end = _n_end;
    e->attr = ht_create(16);
    return e;
}

void edge_add_attr(edge_t* e, char* key, char* val){
    ht_set(e->attr, key, val);
}

void edge_remove_attr(edge_t* e, char* key){
    hashmap_remove(e->attr, key);
}

void edge_load(edge_t* edge, redisContext* context, char* name){
    redisReply* reply;
    reply = redisCommand(context, "GET %s:edges:edge%d:n_start", name, edge->id);
    edge->n_start = reply->integer;
    freeReplyObject(reply);

    reply = redisCommand(context, "GET %s:edges:edge%d:n_end", name, edge->id);
    edge->n_end = reply->integer;
    freeReplyObject(reply);
}

void edge_save(edge_t* edge, redisContext* context, char* name){

    redisReply* reply;
    reply = redisCommand(context, "SET %s:edges:edge%d:n_start %d", name, edge->id, edge->n_start);
    freeReplyObject(reply);

    reply = redisCommand(context, "SET %s:edges:edge%d:n_end %d", name, edge->id, edge->n_end);
    freeReplyObject(reply);
}
