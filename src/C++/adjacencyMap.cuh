#ifndef adjacency_map_h
#define adjacency_map_h

#include <thrust/host_vector.h>

class Adjacency_Map{
    public:
        Adjacency_Map();
        Adjacency_Map(int, int);
        ~Adjacency_Map();

        void add_rows(int);
        void add_columns(int);

        void readjust_rows(int);
        void readjust_columns(int);

        void delete_rows(int);
        void delete_columns(int);

    private:
        thrust::host_vector<int> *rows;
        thrust::host_vector<int> *columns;
};

#endif
