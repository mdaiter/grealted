#include "node.cuh"

/*__global__ void outE(node_t* node, char* str_arr[], int str_n, int* d_in){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    //To avoid using an if statement
    i = max(i, 0);
    i = min(i, str_n);
    char* temp_str = str_arr[i];

}

__global__ void inE(node_t node*, char* str_arr[], int str_n, int* d_in){
    
}*/
