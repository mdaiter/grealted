#include "node.cuh"
#include<cuda.h>
Node::Node(){
    id = -1;
    edges = new std::vector<int>();
    attributes = new std::map<std::string, std::string>();
}

Node::Node(int _id){
    id = _id;
    edges = new std::vector<int>();
    attributes = new std::map<std::string, std::string>();
}

Node::~Node(){
    delete edges;
    delete attributes;
}

void Node::setAttribute(std::string key, std::string value){
    attributes->operator[](key) = value;
}

void Node::setID(int _id){
    id = _id;
}

void Node::addEdge(int _edge){
    edges->push_back(_edge);
}

void Node::removeEdge(int _edge){

}

void Node::removeAttribute(std::string attr){
    attributes->erase(attr);
}

std::vector<int> Node::getEdges(){
    return *edges;
}

std::string Node::getAttribute(std::string key){
    return attributes->operator[](key);
}

int Node::getID(){
    return id;
}


