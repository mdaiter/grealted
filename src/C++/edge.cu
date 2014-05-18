#include "edge.cuh"
#include <cuda.h>

edge_t* edge_init_gpu(int _id, int _n_start, int _n_end){
	edge_t* e;
	cudaMallocManaged(&e, sizeof(edge_t));
	
	e->id = _id;
	e->n_start = _n_start;
	e->n_end = _n_end;
	
	return e;
}


