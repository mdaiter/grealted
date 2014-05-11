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
