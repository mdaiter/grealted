#ifndef edge_h
#define edge_h

#include<map>
#include<string>

class Edge{
    public:
        __host__ Edge();
        __host__ Edge(int);
        __host__ Edge(int, int, int);
        __host__ ~Edge();

        //Getters
        __host__ int get_id();
        __host__ int get_node_end();
        __host__ int get_node_start();
        __host__ std::map<std::string, std::string> get_attributes();
        __host__ std::string get_attribute(std::string);

        //Setters
        __host__ void set_id(int);
        __host__ void set_node_end(int);
        __host__ void set_node_start(int);
        __host__ void set_attribute(std::string, std::string);

        //Remover
        __host__ void remove_attribute(std::string);
    private:
        int id;
        std::map<std::string, std::string> *attributes;
        int node_start;
        int node_end;

};

#endif
