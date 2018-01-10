/* vim: set sw=4 sts=4 et foldmethod=syntax : */

#include "clique.hh"
#include "bit_graph.hh"
#include "template_voodoo.hh"

#include <algorithm>
#include <limits>
#include <iostream>
#include <atomic>
#include <mutex>
#include <numeric>
#include <chrono>
#include <cmath>
#include <utility>

using std::chrono::duration_cast;
using std::chrono::milliseconds;
using std::chrono::steady_clock;

namespace
{
  using Association = std::map<std::pair<unsigned, unsigned>, unsigned>;
  using AssociatedEdges = std::vector<std::pair<unsigned, unsigned> >;

  struct VertexDistance
  {
    int distance;
    int next;
  };

  struct VertexInformation
  {
    std::vector<int> firsts;
    std::vector<VertexDistance> distances;
  };

  auto modular_product(const VFGraph & g1, const VFGraph & g2) -> std::pair<Association, AssociatedEdges>
  {
    unsigned next_vertex = 0;
    Association association;
    AssociatedEdges edges;

    for (unsigned l = 0 ; l < std::min(g1.vertices_by_label.size(), g2.vertices_by_label.size()) ; ++l)
      for (unsigned v1 : g1.vertices_by_label[l])
        for (unsigned v2 : g2.vertices_by_label[l])
          for (unsigned m = 0 ; m < std::min(g1.vertices_by_label.size(), g2.vertices_by_label.size()) ; ++m)
            for (unsigned w1 : g1.vertices_by_label[m])
              for (unsigned w2 : g2.vertices_by_label[m])
                if (v1 != w1 && v2 != w2
                    && (g1.edges[v1][v1] == g2.edges[v2][v2])
                    && (g1.edges[w1][w1] == g2.edges[w2][w2])
                    && (g1.edges[v1][w1] == g2.edges[v2][w2])
                    && (g1.edges[w1][v1] == g2.edges[w2][v2])) {

                  if (! association.count({v1, v2}))
                    association.insert({{v1, v2}, next_vertex++});
                  if (! association.count({w1, w2}))
                    association.insert({{w1, w2}, next_vertex++});

                  edges.push_back({association.find({v1, v2})->second, association.find({w1, w2})->second});
                }

    // Record features/statistics
    unsigned num_edges = 0;
    unsigned max_deg = 0;
    unsigned total_deg = 0;
    bool is_connected = true;
    unsigned distancege2 = 0;
    unsigned distancege3 = 0;
    unsigned distancege4 = 0;
    unsigned sum_distances = 0;
    unsigned max_distance = 0;
    unsigned distance_count = 0;

    // pre-calculate degrees
    std::vector<int> degrees;
    degrees.resize(association.size());
    for (auto & f : edges) {
      ++degrees[f.first];
      ++degrees[f.second];
    }

    for (unsigned i = 0 ; i < association.size(); ++i) {
      if (degrees[i] % 2 == 1)
        throw 0;
      degrees[i] /= 2;
      auto deg = degrees[i];
      total_deg += deg;
      max_deg = std::max<unsigned>(max_deg, deg);
      num_edges += deg;
    }
    double mean_deg = ((0.0 + total_deg) / (0.0 + association.size()));

    /* calculate standard deviation */
    double std_deg = 0;
    for (unsigned i = 0; i < association.size(); i++)
      std_deg += pow(degrees[i] - mean_deg, 2);
    std_deg = sqrt(std_deg / association.size());

    if (0 != num_edges % 2)
      throw 0;
    num_edges /= 2;

    std::vector<VertexInformation> vertices(association.size());

    for (auto & d : vertices) {
      d.firsts.resize(association.size() + 1);
      for (auto & f : d.firsts)
        f = -1;

      d.distances.resize(association.size());
    }

    /* build up distance 1 lists */
    unsigned i = 0;
    for (auto & i_elem : association) {
      int prev = -1;
      unsigned j = 0;
      for (auto & j_elem : association) {
        if (i == j) {
          vertices[i].firsts[0] = i;
          vertices[i].distances[j].distance = 0;
          vertices[i].distances[j].next = -1;
        }
        else if (find(edges.begin(), edges.end(), std::make_pair(i_elem.second, j_elem.second)) != edges.end()) {
          if (-1 == vertices[i].firsts[1]) {
            vertices[i].firsts[1] = j;
            vertices[i].distances[j].distance = 1;
            vertices[i].distances[j].next = -1;
            prev = j;
          }
          else {
            vertices[i].distances[prev].next = j;
            vertices[i].distances[j].distance = 1;
            vertices[i].distances[j].next = -1;
            prev = j;
          }
        }
        else {
          vertices[i].distances[j].distance = -1;
          vertices[i].distances[j].next = -1;
        }
        ++j;
      }
      ++i;
    }

    /* build up distance k lists */
    for (unsigned k = 2 ; k <= association.size() ; ++k) {
      // for each vertex i...
      for (unsigned i = 0 ; i < association.size() ; ++i) {
        int prev = -1;
        // for each vertex a at distance k - 1 from i...
        for (int a = vertices[i].firsts[k - 1] ; a != -1 ; a = vertices[i].distances[a].next) {
          // for each vertex j at distance 1 from a...
          for (int j = vertices[a].firsts[1] ; j != -1 ; j = vertices[a].distances[j].next) {
            // are i and j currently infinitely far apart?
            if (vertices[i].distances[j].distance == -1) {
              // distance from i to j is now k, via a.
              vertices[i].distances[j].distance = k;
              if (-1 == prev)
                vertices[i].firsts[k] = j;
              else
                vertices[i].distances[prev].next = j;
              prev = j;
            }
          }
        }
      }
    }

    for (unsigned i = 0 ; i < association.size() ; ++i)
      for (unsigned j = 0 ; j < association.size() ; ++j) {
        int dist = vertices[i].distances[j].distance;
        if (0 == dist) {
        }
        else if (dist < 0)
          is_connected = false;
        else {
          ++distance_count;
          sum_distances += dist;
          max_distance = std::max(max_distance, unsigned(dist));
          if (dist >= 2) ++distancege2;
          if (dist >= 3) ++distancege3;
          if (dist >= 4) ++distancege4;
        }
      }

    /*std::cout << "vertices = " << association.size() << std::endl;
    std::cout << "edges = " << num_edges << std::endl;
    std::cout << "meandeg = " << mean_deg << std::endl;
    std::cout << "maxdeg = " << max_deg << std::endl;
    std::cout << "stddeg = " << std_deg << std::endl;
    std::cout << "density = " << ((0.0 + 2 * num_edges) / (association.size() * (association.size() - 1))) << std::endl;
    std::cout << "isconnected = " << is_connected << std::endl;
    std::cout << "meandistance = " << ((0.0 + sum_distances) / (0.0 + distance_count)) << std::endl;
    std::cout << "maxdistance = " << max_distance << std::endl;
    std::cout << "proportiondistancege2 = " << ((0.0 + distancege2) / (association.size() * association.size() + 0.0)) << std::endl;
    std::cout << "proportiondistancege3 = " << ((0.0 + distancege3) / (association.size() * association.size() + 0.0)) << std::endl;
    std::cout << "proportiondistancege4 = " << ((0.0 + distancege4) / (association.size() * association.size() + 0.0)) << std::endl;*/
    std::cout << association.size() << "," << num_edges << "," << mean_deg << "," << max_deg << "," << std_deg << ","
              << ((0.0 + 2 * num_edges) / (association.size() * (association.size() - 1))) << "," << is_connected << ","
              << ((0.0 + sum_distances) / (0.0 + distance_count)) << "," << max_distance << ","
              << ((0.0 + distancege2) / (association.size() * association.size() + 0.0)) << std::endl;
    exit(0);

    return { association, edges };
  }

  auto unproduct(const Association & association, unsigned v) -> std::pair<unsigned, unsigned>
  {
    for (auto & a : association)
      if (a.second == v)
        return a.first;

    throw "oops";
  }

  struct Incumbent
  {
    std::atomic<unsigned> value{ 0 };

    std::mutex mutex;
    std::vector<unsigned> c;

    std::chrono::time_point<std::chrono::steady_clock> start_time;

    void update(const std::vector<unsigned> & new_c)
    {
      while (true) {
        unsigned current_value = value;
        if (new_c.size() > current_value) {
          unsigned new_c_size = new_c.size();
          if (value.compare_exchange_strong(current_value, new_c_size)) {
            std::unique_lock<std::mutex> lock(mutex);
            c = new_c;
            std::cerr << "-- " << (duration_cast<milliseconds>(steady_clock::now() - start_time)).count()
                      << " " << new_c.size() << std::endl;
            break;
          }
        }
        else
          break;
      }
    }
  };

  template <unsigned n_words_>
  struct CliqueConnectedMCS
  {
    const Association & association;
    const Params & params;

    FixedBitGraph<n_words_> graph;
    std::vector<int> order, invorder;
    Incumbent incumbent;

    std::atomic<unsigned long long> nodes;

    std::vector<FixedBitSet<n_words_> > vertices_adjacent_to_by_g1;

    CliqueConnectedMCS(const std::pair<Association, AssociatedEdges> & g, const Params & q, const VFGraph & g1) :
      association(g.first),
      params(q),
      order(g.first.size()),
      invorder(g.first.size()),
      nodes(0),
      vertices_adjacent_to_by_g1(g1.size)
    {
      incumbent.start_time = params.start_time;
      incumbent.value = params.prime;

      // populate our order with every vertex initially
      std::iota(order.begin(), order.end(), 0);

      // pre-calculate degrees
      std::vector<int> degrees;
      degrees.resize(g.first.size());
      for (auto & f : g.second) {
        ++degrees[f.first];
        ++degrees[f.second];
      }

      // sort on degree
      std::sort(order.begin(), order.end(),
                [&] (int a, int b) { return true ^ (degrees[a] < degrees[b] || (degrees[a] == degrees[b] && a > b)); });

      // re-encode graph as a bit graph
      graph.resize(g.first.size());

      for (unsigned i = 0 ; i < order.size() ; ++i)
        invorder[order[i]] = i;

      for (auto & f : g.second)
        graph.add_edge(invorder[f.first], invorder[f.second]);

      if (params.connected) {

        for (unsigned i = 0 ; i < g1.size ; ++i) {
          for (int j = 0 ; j < graph.size() ; ++j)
            if (0 != g1.edges.at(i).at(unproduct(association, order[j]).first))
              vertices_adjacent_to_by_g1.at(i).set(j);
        }
      }
    }

    auto colour_class_order(
                            const FixedBitSet<n_words_> & p,
                            std::array<unsigned, n_words_ * bits_per_word> & p_order,
                            std::array<unsigned, n_words_ * bits_per_word> & p_bounds) -> void
    {
      FixedBitSet<n_words_> p_left = p; // not coloured yet
      unsigned colour = 0;         // current colour
      unsigned i = 0;              // position in p_bounds

      // while we've things left to colour
      while (! p_left.empty()) {
        // next colour
        ++colour;
        // things that can still be given this colour
        FixedBitSet<n_words_> q = p_left;

        // while we can still give something this colour
        while (! q.empty()) {
          // first thing we can colour
          int v = q.first_set_bit();
          p_left.unset(v);
          q.unset(v);

          // can't give anything adjacent to this the same colour
          graph.intersect_with_row_complement(v, q);

          // record in result
          p_bounds[i] = colour;
          p_order[i] = v;
          ++i;
        }
      }
    }

    auto connected_colour_class_order(
                                      const FixedBitSet<n_words_> & p,
                                      const FixedBitSet<n_words_> & a,
                                      std::array<unsigned, n_words_ * bits_per_word> & p_order,
                                      std::array<unsigned, n_words_ * bits_per_word> & p_bounds) -> void
    {
      unsigned colour = 0;         // current colour
      unsigned i = 0;              // position in p_bounds

      FixedBitSet<n_words_> p_left = p; // not coloured yet
      p_left.intersect_with_complement(a);

      // while we've things left to colour
      while (! p_left.empty()) {
        // next colour
        ++colour;
        // things that can still be given this colour
        FixedBitSet<n_words_> q = p_left;

        // while we can still give something this colour
        while (! q.empty()) {
          // first thing we can colour
          int v = q.first_set_bit();
          p_left.unset(v);
          q.unset(v);

          // can't give anything adjacent to this the same colour
          graph.intersect_with_row_complement(v, q);

          // record in result
          p_bounds[i] = colour;
          p_order[i] = v;
          ++i;
        }
      }

      p_left = p;
      p_left.intersect_with(a);

      // while we've things left to colour
      while (! p_left.empty()) {
        // next colour
        ++colour;
        // things that can still be given this colour
        FixedBitSet<n_words_> q = p_left;

        // while we can still give something this colour
        while (! q.empty()) {
          // first thing we can colour
          int v = q.first_set_bit();
          p_left.unset(v);
          q.unset(v);

          // can't give anything adjacent to this the same colour
          graph.intersect_with_row_complement(v, q);

          // record in result
          p_bounds[i] = colour;
          p_order[i] = v;
          ++i;
        }
      }
    }

    auto expand_connected(
                          std::vector<unsigned> & c,
                          FixedBitSet<n_words_> & p,
                          const FixedBitSet<n_words_> & a
                          ) -> void
    {
      ++nodes;

      // initial colouring
      std::array<unsigned, n_words_ * bits_per_word> p_order;
      std::array<unsigned, n_words_ * bits_per_word> p_bounds;

      if (! c.empty())
        connected_colour_class_order(p, a, p_order, p_bounds);
      else
        colour_class_order(p, p_order, p_bounds);

      // for each v in p... (v comes later)
      for (int n = p.popcount() - 1 ; n >= 0 ; --n) {
        // bound, timeout or early exit?
        if (c.size() + p_bounds[n] <= incumbent.value || params.abort->load())
          return;

        auto v = p_order[n];

        if (! c.empty() && ! a.test(v))
          break;

        // consider taking v
        c.push_back(v);

        incumbent.update(c);

        // filter p to contain vertices adjacent to v
        FixedBitSet<n_words_> new_p = p;
        graph.intersect_with_row(v, new_p);

        if (! new_p.empty()) {
          FixedBitSet<n_words_> new_a = a;
          new_a.union_with(vertices_adjacent_to_by_g1.at(unproduct(association, order[v]).first));
          expand_connected(c, new_p, new_a);
        }

        // now consider not taking v
        c.pop_back();
        p.unset(v);
      }
    }

    auto expand(
                std::vector<unsigned> & c,
                FixedBitSet<n_words_> & p
                ) -> void
    {
      ++nodes;

      // initial colouring
      std::array<unsigned, n_words_ * bits_per_word> p_order;
      std::array<unsigned, n_words_ * bits_per_word> p_bounds;

      colour_class_order(p, p_order, p_bounds);

      // for each v in p... (v comes later)
      for (int n = p.popcount() - 1 ; n >= 0 ; --n) {
        // bound, timeout or early exit?
        if (c.size() + p_bounds[n] <= incumbent.value || params.abort->load())
          return;

        auto v = p_order[n];

        // consider taking v
        c.push_back(v);

        incumbent.update(c);

        // filter p to contain vertices adjacent to v
        FixedBitSet<n_words_> new_p = p;
        graph.intersect_with_row(v, new_p);

        if (! new_p.empty())
          expand(c, new_p);

        // now consider not taking v
        c.pop_back();
        p.unset(v);
      }
    }

    auto run() -> Result
    {
      std::vector<unsigned> c;
      c.reserve(graph.size());

      FixedBitSet<n_words_> p;
      p.set_up_to(graph.size());

      // go!
      if (params.connected) {
        FixedBitSet<n_words_> a;
        expand_connected(c, p, a);
      }
      else
        expand(c, p);

      Result result;
      result.nodes = nodes;
      for (auto & v : incumbent.c)
        result.isomorphism.insert(unproduct(association, order[v]));

      return result;
    }
  };

  template <template <unsigned> class SGI_>
  struct Apply
  {
    template <unsigned size_, typename> using Type = SGI_<size_>;
  };
}

auto clique_subgraph_isomorphism(const std::pair<VFGraph, VFGraph> & graphs, const Params & params) -> Result
{
  auto product = modular_product(graphs.first, graphs.second);

  return select_graph_size<Apply<CliqueConnectedMCS>::template Type, Result>(AllGraphSizes(), product, params, graphs.first);
}

