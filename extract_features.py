from collections import defaultdict
import os
import sys
import numpy

# This script extracts various features from graphs represented in the LAD format (the SIP instances) and creates a CSV
# file that has a row for each pair of pattern and target graphs

MAIN_DIRECTORY = 'data/sip-instances/'

# ========== Functions to extract features from the adjacency matrix and other (already computed) features ==========

def num_vertices(matrix, data):
    return len(matrix)

def num_loops(matrix, data):
    return sum(matrix[i][i] for i in range(len(matrix)))

def num_edges(matrix, data):
    n = len(matrix)
    return data['number of loops'] + sum(matrix[i][j] for i in range(n) for j in range(i + 1, n))

def density(matrix, data):
    n = len(matrix)
    return data['number of edges']/(n*(n-1)/2+n)

def degs(matrix, data):
    '''A helper function that computes a list of deg v for all vertices v.'''
    n = len(matrix)
    data['degrees'] = [2 * matrix[v][v] + sum(matrix[v][w] for w in range(n) if v != w) for v in range(n)]

def mean_deg(matrix, data):
    degs(matrix, data)
    return sum(data['degrees']) / len(matrix)

def max_deg(matrix, data):
    return max(data['degrees'])

def std_deg(matrix, data):
    return numpy.std(data['degrees'])

def connected(matrix, data):
    n = len(matrix)
    visited = [False] * n
    frontier = [0]
    while len(frontier) > 0:
        vertex = frontier.pop(0)
        visited[vertex] = True
        for neighbour in range(n):
            if matrix[vertex][neighbour] > 0 and not visited[neighbour]:
                frontier.append(neighbour)
    return 1 if all(visited) else 0

def floyd_warshall(matrix, data):
    '''Calculates distance between all pairs of vertices'''
    n = len(matrix)
    dist = []
    for _ in range(n):
        dist.append([float('inf')] * n)
    for v in range(n):
        dist[v][v] = 0
    for u in range(n):
        for v in range(n):
            if matrix[u][v] == 1:
                dist[u][v] = 1
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][j] > dist[i][k] + dist[k][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    data['distances'] = dist

def mean_distance(matrix, data):
    floyd_warshall(matrix, data)
    n = len(matrix)
    distances = [data['distances'][i][j] for i in range(n) for j in range(i, n)]
    return sum(distances) / len(distances)

def max_distance(matrix, data):
    n = len(matrix)
    return max(data['distances'][i][j] for i in range(n) for j in range(i + 1, n))

def dist_apart(k):
    def dist_n_apart(matrix, data):
        total = 0
        far = 0
        n = len(matrix)
        for i in range(n):
            for j in range(i + 1, n):
                total += 1
                if data['distances'][i][j] >= k:
                    far += 1
        return far / total
    return dist_n_apart

features = [('number of vertices', num_vertices), ('number of loops', num_loops), ('number of edges', num_edges),
            ('density', density), ('mean degree', mean_deg), ('maximum degree', max_deg),
            ('standard deviation of degrees', std_deg), ('connected', connected), ('mean distance', mean_distance),
            ('max distance', max_distance), ('number of labels', lambda x, y: 0),
            ('number of distinct labels', lambda x, y: 0)] + [('proportion of pairs of vertices with distance at least ' +
                                                               str(n), dist_apart(n)) for n in range(2, 5)]

# ========== Functions to iterate over all pairs of pattern and target graphs ==========

def for_each_pair1(dataset, output_file, data):
    for root, dirs, files in os.walk(dataset, topdown=False):
        if len(dirs) == 0:
            write_line(output_file, os.path.join(root, 'pattern'), os.path.join(root, 'target'), data)

def for_each_pair2(dataset, output_file, data):
    for root, dirs, files in os.walk(dataset, topdown=False):
        for filename in filter(lambda f: f.endswith('pattern'), files):
            write_line(output_file, os.path.join(root, filename), os.path.join(root, filename.replace('pattern', 'target')), data)

def for_each_pair3(dataset, output_file, data):
    pattern_directory = os.path.join(dataset, 'patterns')
    target_directory = os.path.join(dataset, 'targets')
    for pattern in list_directory(pattern_directory):
        for target in list_directory(target_directory):
            write_line(output_file, pattern, target, data)

def for_each_pair4(dataset, output_file, data):
    files = list(list_directory(dataset))
    for pattern in files:
        for target in files:
            write_line(output_file, pattern, target, data)

def for_each_pair5(dataset, output_file, data):
    for pattern in filter(lambda s: 'pattern' in s, list_directory(dataset)):
        write_line(output_file, pattern, os.path.join(dataset, 'target'), data)

# ========== The rest of the code ==========

def extract_features(filename, data):
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
    for name, function in features:
        data[filename][name] = function(adjacency_matrix, data[filename])

def write_line(output_file, pattern_file, target_file, data):
    '''Writes a single line to the output_file in the CSV format. Also takes two filenames (to identify the instance)
    and the data dictionary.'''
    output_file.write(','.join([pattern_file + ' ' + target_file] +
                               [str(data[filename][feature]) for filename in [pattern_file, target_file]
                                for feature, _ in features]) + '\n')

def list_directory(directory):
    '''Returns a directory listing with the directory prefixed to each file '''
    return map(lambda s: os.path.join(directory, s), os.listdir(directory))

def process_dataset(dataset, output_file, for_each_pair):
    '''Takes a name of a dataset we want to extract features from, an already opened output file, and a function that
    iterates over all pairs of pattern and target graphs and calls write_line() for each pair. Creates a dictionary
    mapping instance name to the dictionary returned by extract_features() and calls for_each_pair().'''
    # Collect the date about each graph
    data = defaultdict(dict)
    for root, dirs, files in os.walk(MAIN_DIRECTORY + dataset, topdown=False):
        for name in files:
            filename = os.path.join(root, name)
            print(filename)
            extract_features(filename, data)

    # Write the data about each relevant pair of graphs
    for_each_pair(MAIN_DIRECTORY + dataset, output_file, data)

with open(sys.argv[1], 'w') as output_file:
    output_file.write(','.join(['ID'] + [graph + ' ' + name for graph in ['pattern', 'target'] for name, _ in features]) + '\n')
    process_dataset('si', output_file, for_each_pair1)
    process_dataset('scalefree', output_file, for_each_pair1)
    process_dataset('phase', output_file, for_each_pair2)
    process_dataset('meshes-CVIU11', output_file, for_each_pair3)
    process_dataset('LV', output_file, for_each_pair4)
    process_dataset('largerGraphs', output_file, for_each_pair4)
    process_dataset('images-PR15', output_file, for_each_pair5)
    process_dataset('images-CVIU11', output_file, for_each_pair3)
