#ifndef node_h
#define node_h

#include<vector>
#include<map>
#include<string>
class Node{
    public:
        __host__ Node();
        __host__ Node(int);
        __host__ ~Node();

        //Setters
        __host__ void setAttribute(std::string, std::string);
        __host__ void setID(int);
        __host__ void addEdge(int);

        //Removers
        __host__ void removeEdge(int);
        __host__ void removeAttribute(std::string);

        //Getters
        __host__ __device__ std::vector<int> getEdges();
        __host__ __device__ std::string getAttribute(std::string);
        __host__ __device__ int getID();

    private:
        int id;
        std::vector<int> *edges;
        std::map<std::string, std::string> *attributes;
};

#endif
