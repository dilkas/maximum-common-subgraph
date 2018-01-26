CXX := g++
CXXFLAGS := -O3 -march=native
all: mcsp

mcsp: mcsp.c graph.c graph.h
	$(CXX) $(CXXFLAGS) -Wall -std=c++11 -o mcsp graph.c clique.cc bit_graph.cc mcsp.c -pthread
