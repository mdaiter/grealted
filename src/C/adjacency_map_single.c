#include <stdlib.h>
#include "adjacency_map_single.h"
#include <stdio.h>

adjacency_map_t* adjacency_map_init(int num_nodes){
    adjacency_map_t *map = (adjacency_map_t*)malloc(sizeof(adjacency_map_t));

    map->connections = (int*)malloc(sizeof(int) * num_nodes * num_nodes);

    map->width = num_nodes;
    map->height = num_nodes;
    //Fill this thang with 0s

    map->stride = 0;
    return map;

}

void adjacency_map_resize(adjacency_map_t* map, int new_size){
    map->width = new_size;
    map->height = new_size;

    map->connections = (int*) realloc(map->connections, new_size * new_size * sizeof(int));
}
