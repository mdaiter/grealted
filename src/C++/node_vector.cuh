#ifndef node_vector_cuh
#define node_vector_cuh

extern "C"{
#include "../C/node.h"
}

typedef struct node_vector{
	int size;
	node_t** stuff;
} node_vector_t;

node_vector_t* node_vector_init(int);

void node_vector_add(node_vector_t*, node_t*);

node_t** node_vector_raw_pointer(node_vector_t*);

#endif
