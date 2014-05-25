#ifndef node_h
#define node_h

#include "../C++/hash.cuh"
#include "kvec.h"
#include "../../hiredis/hiredis.h"
#include<stdbool.h>
typedef struct node_t {
    int id;
    hashtable_t* attr;
    kvec_t(int) edges;
    bool is_selected;
} node_t;

node_t* node_init(int);

void node_add_attr(node_t*, char*, char*);

char* node_get_attr(node_t*, char*);

void node_remove_attr(node_t*, char*);

void node_set_id(node_t*, int);

void node_add_edge(node_t*, int);

void node_remove_edge(node_t*, int);

void node_destroy(node_t*);

void node_load(node_t*, redisContext*, char*);

void node_save(node_t*, redisContext*, char*);

#endif
