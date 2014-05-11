#ifndef edge_h
#define edge_h

#include<map>
#include<string>

class Edge{
    public:
        Edge();
        Edge(int);
        Edge(int, int, int);
        ~Edge();

        //Getters
        int get_id();
        int get_node_end();
        int get_node_start();
        std::map<std::string, std::string> get_attributes();
        std::string get_attribute(std::string);

        //Setters
        void set_id(int);
        void set_node_end(int);
        void set_node_start(int);
        void set_attribute(std::string, std::string);

        //Remover
        void remove_attribute(std::string);
    private:
        int id;
        std::map<std::string, std::string> *attributes;
        int node_start;
        int node_end;

};

#endif
