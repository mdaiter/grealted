typedef struct adjacency_map{
    int width;
    int height;
    int* connections;
    //To avoid coalescing
    int stride;
} adjacency_map_t;

adjacency_map_t* adjacency_map_init_cpu(int);

void adjacency_map_single_resize(adjacency_map_t*, int);
