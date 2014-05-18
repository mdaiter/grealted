#ifndef ADJACENCY_MAP_CUH
#define ADJACENCY_MAP_CUH

#ifdef __cplusplus
extern "C"{
#endif

#include "../C/edge.h"
#include "../C/adjacency_map_single.h"

#ifdef __cplusplus
}
#endif

adjacency_map_t* adjacency_map_init(int, edge_t**, int);

void adjacency_map_resize(adjacency_map_t* map, int);

#endif
