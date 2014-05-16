#ifndef redis_client_h
#define redis_client_h

#include "../../hiredis/hiredis.h"
#include "edge.h"
#include "node.h"

int redis_client_get_node_size(redisContext*, char*);

int redis_client_get_edge_size(redisContext*, char*);

void redis_client_set_node_size(redisContext*, char*, int);

void redis_client_set_edge_size(redisContext*, char*, int);

int redis_client_save_nodes(redisContext*, node_t*);

int redis_client_save_edges(redisContext*, edge_t*);

#endif
