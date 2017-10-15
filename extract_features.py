import os
import numpy

def num_vertices(matrix):
    return len(matrix)

def num_edges(matrix):
    return num_loops(matrix) + sum(matrix[i][j] for i in range(len(matrix)) for j in range(len(matrix[i])) if i != j)/2

def density(matrix):
    n = num_vertices(matrix)
    return num_edges(matrix)/(n*(n-1)/2+n)

def num_loops(matrix):
    return sum(matrix[i][i] for i in range(len(matrix)))

def degs(matrix):
    '''A helper function that returns a list of deg v for all vertices v.'''
    return [2 * matrix[v][v] + sum(matrix[v][w] for w in range(len(matrix[v])) if v != w) for v in range(num_vertices(matrix))]

def mean_deg(matrix):
    return sum(degs(matrix)) / num_vertices(matrix)

def max_deg(matrix):
    return max(degs(matrix))

def std_deg(matrix):
    return numpy.std(degs(matrix))

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
            for j in list(map(int, line.split()))[1:]:
                adjacency_matrix[i][j] += 1
    return dict((name, function(adjacency_matrix)) for name, function in features)

def process_dataset(dataset):
    data = {}
    for root, dirs, files in os.walk('data/sip-instances/' + dataset, topdown=False):
        for name in files:
            filename = os.path.join(root, name)
            print(filename)
            data[filename] = extract_features(filename)

    for root, dirs, files in os.walk('data/sip-instances/' + dataset, topdown=False):
        if len(dirs) == 0:
            pattern_file = os.path.join(root, 'pattern')
            target_file = os.path.join(root, 'target')
            output_file.write(','.join([pattern_file + ' ' + target_file] +
                                       [str(data[filename][feature]) for filename in [pattern_file, target_file]
                                        for feature, _ in features]) + '\n')

with open('results/features.csv', 'w') as output_file:
    output_file.write(','.join(['ID'] + [graph + ' ' + name for graph in ['pattern', 'target'] for name, _ in features]) + '\n')
    #process_dataset('si')
    process_dataset('scalefree')
