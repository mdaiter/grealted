#include "edge.h"
#include <stdlib.h>

void edge_init(edge_t* e, int _id, int _n_start, int _n_end){
    e = (edge_t*) malloc(sizeof(edge_t));
    e->id = _id;
    e->n_start = _n_start;
    e->n_end = _n_end;
}

void edge_add_attr(edge_t* e, char* key, any_t val){
    hashmap_put(e->attr, key, val);
}

void edge_remove_attr(edge_t* e, char* key){
    hashmap_remove(e->attr, key);
}
