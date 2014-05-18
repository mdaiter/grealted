#include "edge.cuh"
#include <cuda.h>

node_t* node_init_gpu(int _id){
	node_t* e;
	cudaMallocManaged(&e, sizeof(node_t));
	
	e->id = _id;
	
	return e;
}


