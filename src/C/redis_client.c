#include "redis_client.h"
#include <stdlib.h>

int redis_client_get_node_size(redisContext* c, char* name_of_graph){
    redisReply *reply;
    reply = redisCommand(c,"GET %s:nodes:size", name_of_graph);
    int repl = atoi(reply->str);
    freeReplyObject(reply);
    return repl;
}

int redis_client_get_edge_size(redisContext* c, char* name_of_graph){
    redisReply* reply;
    reply = redisCommand(c, "GET %s:edges:size", name_of_graph);
    int repl = atoi(reply->str);
    freeReplyObject(reply);
    return repl;
}

void redis_client_set_node_size(redisContext* c, char* name_of_graph, int size){
    redisCommand(c, "SET %s:nodes:size %d", name_of_graph, size);
}

void redis_client_set_edge_size(redisContext* c, char* name_of_graph, int size){
    redisCommand(c, "SET %s:edges:size %d", name_of_graph, size);
}
