#ifndef adjacency_map_h
#define adjacency_map_h

#include "kvec.h"

//One shot this; only instantiate ONE per graph. Takes up space, etc.
typedef struct adjacency_map{
    kvec_t(kvec_t(int)) rows;
    kvec_t(int) cols; 
} adjacency_map;

void adjacency_map_init(adjacency_map*, int, int);

__global__ void adjacency_map_add(adjacency_map*, int, int);

__device__ void fill(adjacency_map*, int, int);

__global__ void adjacency_map_remove_row(adjacency_map*, int);

__global__ void adjacency_map_remove_column(adjacency_map*, int);

#endif
