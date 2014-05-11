#include "adjacencyMap.cuh"


Adjacency_Map::Adjacency_Map(){
    rows = new thrust::host_vector<int>();
    columns = new thrust::host_vector<int>();
}

Adjacency_Map::Adjacency_Map(int row_num, int col_num){
    rows = new thrust::host_vector<int>(row_num);
    columns = new thrust::host_vector<int>(col_num);
}

Adjacency_Map::~Adjacency_Map(){
    delete rows;
    delete columns;
}
