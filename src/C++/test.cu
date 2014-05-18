#include <cuda.h>
#include "edge_vector.cuh"
#include "edge.cuh"
#include <stdio.h>

int main(){
	edge_vector_t* vec = edge_vector_init(0);
	
	edge_t* n1 = edge_init_gpu(1, 2, 2);
	edge_t* n2 = edge_init_gpu(2, 1, 2);
	
	edge_vector_add(vec, n1);
	edge_vector_add(vec, n2);
	printf("%d %d \n", vec->stuff[0]->id, vec->stuff[1]->id );
	return 0;
}
