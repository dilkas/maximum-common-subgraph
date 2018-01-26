/* vim: set sw=4 sts=4 et foldmethod=syntax : */

#ifndef CODE_GUARD_CLIQUE_HH
#define CODE_GUARD_CLIQUE_HH 1

#include "params.hh"
#include "result.hh"

#include <vector>
#include <tuple>

struct VFGraph
{
    unsigned size;
    std::vector<unsigned> vertex_labels;
    std::vector<std::vector<unsigned> > vertices_by_label;
    std::vector<std::vector<unsigned> > edges;
};

using Association = std::map<std::pair<unsigned, unsigned>, unsigned>;
using AssociatedEdges = std::vector<std::pair<unsigned, unsigned> >;

auto clique_subgraph_isomorphism(const std::pair<VFGraph, VFGraph> & graphs, const Params & params) -> Result;
auto mcsplit_run(std::pair<Association, AssociatedEdges> product,
                 const Params & params, VFGraph & g0) -> Result;
#endif
