#include "edge.cuh"

Edge::Edge(){
    id = -1;
    attributes = new std::map<std::string, std::string>();
    node_start = -1;
    node_end = -1;
}

Edge::Edge(int _id){
    id = _id;
    attributes = new std::map<std::string, std::string>();
    node_start = -1;
    node_end = -1;
}

Edge::Edge(int _id, int _node_start, int _node_end){
    id = _id;
    node_start = _node_start;
    node_end = _node_end;
    attributes = new std::map<std::string, std::string>();
}

int Edge::get_id(){
    return id;
}

int Edge::get_node_start(){
    return node_start;
}

int Edge::get_node_end(){
    return node_end;
}

std::map<std::string, std::string> Edge::get_attributes(){
    return *attributes;
}

std::string Edge::get_attribute(std::string key){
    return attributes->operator[](key);
}

void Edge::set_id(int _id){
    id = _id;
}

void Edge::set_node_end(int _node_end){
    node_end = _node_end;
}

void Edge::set_node_start(int _node_start){
    node_start = _node_start;
}

void Edge::set_attribute(std::string key, std::string value){
    attributes->operator[](key) = value;
}

void Edge::remove_attribute(std::string key){
    attributes->erase(key);
}

Edge::~Edge(){
    delete attributes;
}
