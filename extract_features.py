import os
import numpy

def num_vertices(matrix):
    return len(matrix)

def num_edges(matrix):
    return sum(sum(row) for row in matrix)/2

def density(matrix):
    n = num_vertices(matrix)
    return 2*num_edges(matrix)/(n*(n-1))

def num_loops(matrix):
    return sum(matrix[i][i] for i in range(len(matrix)))

def mean_deg(matrix):
    return 2*num_edges(matrix)/num_vertices(matrix)

def max_deg(matrix):
    return max(sum(row) for row in matrix)

def std_deg(matrix):
    return numpy.std(numpy.array(matrix), axis=1)

def connected(matrix):
    pass

def mean_distance(matrix):
    pass

def max_distance(matrix):
    pass

def dist_apart(n, matrix):
    def dist_n_apart(matrix):
        pass
    return dist_n_apart

features = [('number of vertices', num_vertices), ('number of edges', num_edges), ('density', density),
            ('number of loops', num_loops), ('mean degree', mean_deg), ('maximum degree', max_deg),
            ('standard deviation of degrees', std_deg)]

def extract_features(filename):
    with open(filename) as graph:
        order = int(graph.readline())
        adjacency_matrix = []
        for _ in range(order):
            adjacency_matrix.append([0] * order)
            for i, line in enumerate(graph):
                for j in map(int, line.split()):
                    adjacency_matrix[i][j] = 1

    return dict((name, function(adjacency_matrix)) for name, function in features)

for root, dirs, files in os.walk('data/sip-instances/', topdown=False):
    for name in files:
        os.path.join(root, name)
