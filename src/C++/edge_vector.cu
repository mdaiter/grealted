#include "edge_vector.cuh"
#include <cuda.h>

edge_vector_t* edge_vector_init(int size){
	edge_vector_t* vec;
	cudaMallocManaged(&vec, sizeof(edge_vector_t));
	cudaMallocManaged(&(vec->stuff), sizeof(edge_t*) * size);
	vec->size = size;
	return vec;
}

void edge_vector_add(edge_vector_t* vec, edge_t* new_element){
	edge_t** vec2;
	cudaMallocManaged(&vec2, sizeof(edge_t*) * (vec->size + 1));
	cudaMemcpy(vec2, vec->stuff, sizeof(edge_t*) * (vec->size), cudaMemcpyHostToHost);
	cudaFree(vec->stuff);
	vec->stuff = vec2;
	vec->size++;
	vec->stuff[vec->size - 1] = new_element;
}

edge_t** edge_vector_raw_pointer(edge_vector_t* vec){
	return vec->stuff;
}
