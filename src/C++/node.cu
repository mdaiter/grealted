#include "edge.cuh"
#include <cuda.h>
#include "../C/node.h"
#include "../C/kvec.h"
node_t* node_init_gpu(int _id){
	node_t* e;
	cudaMallocManaged(&e, sizeof(node_t));
	e->attr = ht_create(16);
	//Add sample to hashtable
	ht_set(e->attr, "", "");
	kv_init(e->edges);
	e->id = _id;
	return e;
}


