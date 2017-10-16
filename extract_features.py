import os
import numpy

# This script extracts various features from graphs represented in the LAD format (the SIP instances) and writes them
# to a CSV file for each relevant (pattern, target) pair

MAIN_DIRECTORY = 'data/sip-instances/'
OUTPUT_FILENAME = 'results/sip_features.csv'

# ========== Functions to extract features from the adjacency matrix ==========

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

# ========== The rest of the code ==========

def extract_features(filename):
    '''Reads the file, builds an adjacency matrix, calls all the feature functions on it, and returns a dictionary
    mapping feature names to the numbers returned by their corresponding functions'''
    with open(filename) as graph:
        order = int(graph.readline())
        adjacency_matrix = []
        for _ in range(order):
            adjacency_matrix.append([0] * order)
        for i, line in enumerate(graph):
            for j in list(map(int, line.split()))[1:]:
                adjacency_matrix[i][j] += 1
    return dict((name, function(adjacency_matrix)) for name, function in features)

def write_line(output_file, pattern_file, target_file, data):
    '''Writes a single line to the output_file in the CSV format. Also takes two filenames (to identify the instance)
    and the data dictionary.'''
    output_file.write(','.join([pattern_file + ' ' + target_file] +
                               [str(data[filename][feature]) for filename in [pattern_file, target_file]
                                for feature, _ in features]) + '\n')

def for_each_pair1(dataset, output_file, data):
    for root, dirs, files in os.walk(MAIN_DIRECTORY + dataset, topdown=False):
        if len(dirs) == 0:
            write_line(output_file, os.path.join(root, 'pattern'), os.path.join(root, 'target'), data)

def for_each_pair2(dataset, output_file, data):
    for root, dirs, files in os.walk(MAIN_DIRECTORY + dataset, topdown=False):
        for filename in filter(lambda f: f.endswith('pattern'), files):
            write_line(output_file, os.path.join(root, filename), os.path.join(root, filename.replace('pattern', 'target')), data)

def process_dataset(dataset, output_file, for_each_pair):
    '''Takes a name of a dataset we want to extract features from, an already opened output file, and a function that
    iterates over all pairs of pattern and target graphs and calls write_line() for each pair. Creates a dictionary
    mapping instance name to the dictionary returned by extract_features() and calls for_each_pair().'''
    # Collect the date about each graph
    data = {}
    for root, dirs, files in os.walk(MAIN_DIRECTORY + dataset, topdown=False):
        for name in files:
            filename = os.path.join(root, name)
            print(filename)
            data[filename] = extract_features(filename)

    # Write the data about each relevant pair of graphs
    for_each_pair(dataset, output_file, data)

with open(OUTPUT_FILENAME, 'w') as output_file:
    output_file.write(','.join(['ID'] + [graph + ' ' + name for graph in ['pattern', 'target'] for name, _ in features]) + '\n')
    #process_dataset('si', output_file, for_each_pair1)
    #process_dataset('scalefree', output_file, for_each_pair1)
    process_dataset('phase', output_file, for_each_pair2)
