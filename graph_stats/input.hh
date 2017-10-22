/* vim: set sw=4 sts=4 et foldmethod=syntax : */

#ifndef GUARD_INPUT_HH
#define GUARD_INPUT_HH 1

#include "graph.hh"

#include <string>

/**
 * Thrown if we come across bad data in a graph file, or if we can't read a
 * graph file.
 */
class GraphFileError :
    public std::exception
{
    private:
        std::string _what;

    public:
        GraphFileError(const std::string & filename, const std::string & message) throw ();

        auto what() const throw () -> const char *;
};

/**
 * Read a LAD format file into a Graph.
 *
 * \throw GraphFileError
 */
auto read_lad(const std::string & filename) -> Graph;

auto read_vf(const std::string & filename, bool unlabelled, bool no_edge_labels) -> Graph;

#endif
