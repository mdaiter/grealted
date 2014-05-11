#include "adjacency_map.cuh"
#include <stdlib.h>
#include <cuda.h>

void adjacency_map_init(adjacency_map* map, int row_num, int col_num){
    map = (adjacency_map*) malloc(sizeof(adjacency_map));

    kv_init(map->rows);
}

__global__ void adjacency_map_add(adjacency_map* map, int new_row_num, int new_col_num){
    int i = threadIdx.x + blockIdx.x * blockDim.x;

}
