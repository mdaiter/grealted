#ifndef edge_vector_cuh
#define edge_vector_cuh

extern "C"{
#include "../C/edge.h"
}

typedef struct edge_vector{
	int size;
	edge_t** stuff;
} edge_vector_t;

edge_vector_t* edge_vector_init(int);

void edge_vector_add(edge_vector_t*, edge_t*);

edge_t** edge_vector_raw_pointer(edge_vector_t*);

#endif
