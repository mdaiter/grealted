#include "node_vector.cuh"
#include <cuda.h>

node_vector_t* node_vector_init(int size){
	node_vector_t* vec;
	cudaMallocManaged(&vec, sizeof(node_vector_t));
	cudaMallocManaged(&(vec->stuff), sizeof(node_t*) * size);
	vec->size = size;
	return vec;
}

void node_vector_add(node_vector_t* vec, node_t* new_element){
	node_t** vec2;
	cudaMallocManaged(&vec2, sizeof(node_t*) * (vec->size + 1));
	cudaMemcpy(vec2, vec->stuff, sizeof(node_t*) * (vec->size), cudaMemcpyHostToHost);
	cudaFree(vec->stuff);
	vec->stuff = vec2;
	vec->size++;
	vec->stuff[vec->size - 1] = new_element;
}

node_t** node_vector_raw_pointer(node_vector_t* vec){
	return vec->stuff;
}
