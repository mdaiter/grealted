#include <stdlib.h>
#include "adjacency_map_single.h"
#include <stdio.h>
#include "edge.h"

__global__ void adjacency_map_init_gpu(adjacency_map_t* map){
    int row = threadIdx.y + blockIdx.y * blockDim.y;
    int col = threadIdx.x + blockIdx.x * blockDim.x;

    int i = row * map->width + col;
    
    max(i, 0);
    min(i, map->width * map->height);

    map->connections[i] = 0;
}

__global__ void adjacency_map_connect_gpu(edge_t* edges, int num_edges, adjacency_map_t* map){
    
    int i = threadIdx.x + (((gridDim.x * blockIdx.y) + blockIdx.x)*blockDim.x);

    max(i, 0);
    min(i, num_edges);

    int n_start = edges[i].n_start;
    int n_end = edges[i].n_end;
    
    int map_index = n_start * map->width + n_end;
    map->connections[map_index] = 1;
    printf("%d new value: %d\n", map_index, map->connections[map_index]);
}

adjacency_map_t* adjacency_map_init(int num_nodes, edge_t* edges, int num_edges){
    adjacency_map_t *map;// = (adjacency_map_t*)malloc(sizeof(adjacency_map_t));
    cudaMallocManaged(&map, sizeof(adjacency_map_t));
    cudaMallocManaged(&(map->connections), num_nodes * num_nodes * sizeof(int));
    //map->connections = (int*)malloc(sizeof(int) * num_nodes * num_nodes);

    map->width = num_nodes;
    map->height = num_nodes;

    map->stride = 0;
    
    //GPU stuff
//    adjacency_map_t *d_map;
//    int* d_connections;

//    cudaMalloc((void**) &d_map, sizeof(adjacency_map_t));
//    cudaMalloc((void**) &d_connections, num_nodes * num_nodes * sizeof(int));
    
//    cudaMemcpy(d_map, map, sizeof(adjacency_map_t), cudaMemcpyHostToDevice);
//    cudaMemcpy(d_connections, map->connections, num_nodes * num_nodes, cudaMemcpyHostToDevice);
    //cudaMemcpy(&(d_map->connections), &d_connections, sizeof(int*), cudaMemcpyHostToDevice);

//    edge_t* d_edges;
//    cudaMalloc((void**) &d_edges, num_edges * sizeof(edge_t));
//    cudaMemcpy(d_edges, edges, num_edges * sizeof(edge_t), cudaMemcpyHostToDevice);

    adjacency_map_init_gpu<<<1, 3>>>(map);
    cudaDeviceSynchronize();
    //adjacency_map_connect_gpu<<<1, 3>>>(edges, num_edges, map);
    
    cudaDeviceSynchronize();

//    cudaMemcpy(map, d_map, sizeof(adjacency_map_t), cudaMemcpyDeviceToHost);
    //Synchronize everything
//    cudaFree(map);
//    cudaFree(edges);

    return map;

}

int main(){
    edge_t* edges;// = (edge_t*) malloc(sizeof(edge_t) * 3);
    cudaMallocManaged(&edges, 3 * sizeof(edge_t));
    
    edges[0].id = 2;
    edges[0].n_start = 1 ;
    edges[0].n_end = 2;
    
    edges[1].id = 0;
    edges[1].n_start = 2;
    edges[1].n_end = 1;

    edges[2].id = 1;
    edges[2].n_start = 1;
    edges[2].n_end = 1;

    adjacency_map_t* map = adjacency_map_init(3, edges, 3);
    printf("[ %d %d %d\n%d %d %d\n%d %d %d]", map->connections[0], map->connections[1], map->connections[2], map->connections[3], map->connections[4], map->connections[5], map->connections[6], map->connections[7], map->connections[8]);
    return 0;
}

void adjacency_map_resize(adjacency_map_t* map, int new_size){
    map->width = new_size;
    map->height = new_size;

    map->connections = (int*) realloc(map->connections, new_size * new_size * sizeof(int));
}
