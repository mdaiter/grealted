#ifndef edge_h
#define edge_h

#include "hashmap.h"
#include "kvec.h"

typedef struct edge_t{
    int id;
    map_t attr;
    int n_start;
    int n_end;
} edge_t;

void edge_init(edge_t*, int, int, int);

void edge_add_attr(edge_t*, char*, any_t);

void edge_remove_attr(edge_t*, char*);

#endif
