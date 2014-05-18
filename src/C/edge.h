#ifndef edge_h
#define edge_h

#include "../C++/hash.cuh"
#include "kvec.h"
#include "../../hiredis/hiredis.h"

typedef struct edge_t{
    int id;
    hashtable_t* attr;
    int n_start;
    int n_end;
} edge_t;

edge_t* edge_init(int, int, int);

void edge_add_attr(edge_t*, char*, char*);

void edge_remove_attr(edge_t*, char*);

void edge_load(edge_t*, redisContext*, char*);

void edge_save(edge_t*, redisContext*, char*);

#endif
