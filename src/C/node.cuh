#ifndef node_cuh
#define node_cuh

#include "node.h"

__global__ void outE(node_t*, char*[], int, int*);

__global__ void inE(node_t*, char*[], int, int*);

#endif
