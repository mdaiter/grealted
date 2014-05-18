#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>
#include "adjacency_map_single.cuh"
__global__ void adjacency_map_init_gpu(adjacency_map_t* map){
    int row = threadIdx.y + blockIdx.y * blockDim.y;
    int col = threadIdx.x + blockIdx.x * blockDim.x;

    int i = row * map->width + col;
    
    max(i, 0);
    min(i, map->width * map->height);

    map->connections[i] = 0;
}

__global__ void adjacency_map_connect_gpu(edge_t** edges, int num_edges, adjacency_map_t* map){
    
    int i = threadIdx.x + (((gridDim.x * blockIdx.y) + blockIdx.x)*blockDim.x);

    max(i, 0);
    min(i, num_edges);

    int n_start = edges[i]->n_start;
    int n_end = edges[i]->n_end;
    
    int map_index = n_start * map->width + n_end;
    map->connections[map_index] = 1;
}

adjacency_map_t* adjacency_map_init(int num_nodes, edge_t** edges, int num_edges){
    adjacency_map_t *map;// = (adjacency_map_t*)malloc(sizeof(adjacency_map_t));
    cudaMallocManaged(&map, sizeof(adjacency_map_t));
    cudaMallocManaged(&(map->connections), num_nodes * num_nodes * sizeof(int));

    map->width = num_nodes;
    map->height = num_nodes;

    map->stride = 0;
    
    //GPU stuff

    adjacency_map_init_gpu<<<1, num_nodes * num_nodes>>>(map);
    cudaDeviceSynchronize();
    adjacency_map_connect_gpu<<<1, num_edges>>>(edges, num_edges, map);
    
    cudaDeviceSynchronize();

    return map;

}

void adjacency_map_resize(adjacency_map_t* map, int new_size){
    map->width = new_size;
    map->height = new_size;

    map->connections = (int*) realloc(map->connections, new_size * new_size * sizeof(int));
}
