#    Copyright (C) 2018 Queen's University Belfast
#
#
#    itercut.py is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    itercut.py is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with itercut.py in the file LICENSE.txt
#    If not, see <http://www.gnu.org/licenses/>.
#
#    Contact: Ian Overton - i.overton@qub.ac.uk
#

# -*- coding: utf-8 -*-
"""
@author: Jeremy A. Owen
@author: Ian Overton
"""
import networkx as nx
import sys
import getopt
from networkx.algorithms import flow  # Import the flow submodule


def weighted_minimum_edge_cut(graph):
    """Performs the global minimum cut of a weighted graph and returns the cutset.
    Note that since the graph object is mutable this function has side-effects.

    >>> import networkx as nx
    >>> g1 = nx.Graph([('A','B',{'weight':2}), ('B','C',{'weight':1}), ('A','C',{'weight':1})])
    >>> weighted_minimum_edge_cut(g1) == {('A', 'C'), ('B', 'C')}
    True
    >>> g2 = nx.Graph([('A','B',{'weight':1}), ('B','C',{'weight':2}), ('A','C',{'weight':1})])
    >>> weighted_minimum_edge_cut(g2) == {('A', 'B'), ('A', 'C')}
    True
    >>> g3 = nx.Graph([('A','B',{'weight':1}), ('B','C',{'weight':1}), ('A','C',{'weight':2})])
    >>> weighted_minimum_edge_cut(g3) == {('A', 'B'), ('B', 'C')}
    True
    >>> g4 = nx.Graph([('A','B',{'weight':1}), ('B','C',{'weight':1}), ('A','C',{'weight':1}),('C','D',{'weight':1})])
    >>> weighted_minimum_edge_cut(g4) == {('C', 'D')}
    True
    >>> g5 = nx.Graph([('A','B',{'weight':3}), ('B','C',{'weight':1}), ('A','C',{'weight':1}),('C','D',{'weight':3})])
    >>> weighted_minimum_edge_cut(g5) == {('A', 'C'), ('B', 'C')}
    True
    """
    nodes = list(graph.nodes)
    if not nodes:
        return set()
    cut_value, partition = nx.stoer_wagner(graph, weight='weight')
    set1, set2 = partition
    best_cut = set()
    for u, v in graph.edges():
        if (u in set1 and v in set2) or (v in set1 and u in set2):
            best_cut.add((u, v))
    return best_cut

def iterative_minimum_cut(graph, cut_crit):
    """Iteratively cuts the input graph until all the 'cut products' (connected subgraphs)
    fail to satisfy cut_crit. Also this function has side-effects (changes the input graph).
    """
    cutset = set()
    while True:
        components = [graph.subgraph(c).copy() for c in nx.connected_components(graph)]
        components_to_cut = [comp for comp in components if cut_crit(comp)]
        if not components_to_cut:
            break
        for component in components_to_cut:
            cut = weighted_minimum_edge_cut(component)
            cutset.update(cut)
        graph.remove_edges_from(cutset)
    return cutset


def density_cutoff(cutoff):
    def cut_crit(graph):
        if not graph.number_of_edges():
            return False
        density = nx.density(graph)
        if density == 0.0:
            return False
        if density >= cutoff:
            return False
        return True

    return cut_crit


def highlight_graph(graph, clusters=None, pos=None, myprog='neato', cmap=None):
    import random
    if clusters is None:
        clusters = [list(graph.nodes)]
    random.shuffle(clusters)
    node_colors = {}
    for i, cluster in enumerate(clusters):
        for node in cluster:
            node_colors[node] = i
    indices = [node_colors[node] for node in graph.nodes]

    try:
        if pos is None:
            pos = nx.nx_agraph.graphviz_layout(graph, prog=myprog)
    except ImportError:
        if pos is None:
            pos = nx.spring_layout(graph, iterations=50)
    nx.draw(graph, pos, node_color=indices, node_size=100, cmap=cmap, with_labels=False)


def main():
    """
    USAGE: itercut.py -i [graphfile.txt] -o [outputfile.txt]
    -t [density threshold value] [-v] [-h]

    Mandatory arguments:
    -i: name of input graph file (table of edges, tab-delimited)

    Optional arguments:
    -o: name of output file (default = input name with _OUT appended)
    -t: threshold density value for iterative cut algorithm (default = 0.1)
    -v: output a PNG showing the graph with nodes colored by predicted pathway
    (requires matplotlib and pygraphviz or pydot)
    -c: output a file with the edges cut by the algorithm
    -h: print this help message
    """
    graph_file = None
    output_file = None
    visualize = False
    write_cutset = False
    cutoff = 0.1
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hi:o:t:vc", ["help"])
    except getopt.GetoptError as err:
        print((str(err)))
        print((main.__doc__))
        sys.exit(2)
    for opt, val in opts:
        if opt == "-i":
            graph_file = val
        elif opt in ("-h", "--help"):
            print((main.__doc__))
            sys.exit()
        elif opt == "-o":
            output_file = val
        elif opt == "-t":
            cutoff = float(val)
        elif opt == "-v":
            visualize = True
        elif opt == "-c":
            write_cutset = True
        else:
            assert False, "unhandled option"
    if graph_file is None:
        print((main.__doc__))
        sys.exit(2)
    if output_file is None:
        name_core = ".".join(graph_file.split(".")[:-1])
        output_file = name_core + "_OUT" + ".txt"
    else:
        name_core = ".".join(output_file.split(".")[:-1])
    try:
        G = nx.read_weighted_edgelist(graph_file, delimiter='\t')
    except FileNotFoundError:
        print(f"Error: Input graph file '{graph_file}' not found.")
        sys.exit(2)
    except Exception as e:
        print(f"Error reading graph file: {e}")
        sys.exit(2)

    result = iterative_minimum_cut(G.copy(), density_cutoff(cutoff))  # Operate on a copy

    if write_cutset:
        outfile = open(name_core + "_CUTSET" + ".txt", 'w')
        for edge in result:
            outfile.write("%s\n" % str(edge))
        outfile.close()
    nx.write_weighted_edgelist(G, output_file, delimiter='\t')
    if visualize:
        try:
            clusters = list(nx.connected_components(G))
            G_visual = G.copy()
            G_visual.add_edges_from(result, weight=0)  # Add cut edges for visualization
            import matplotlib.pyplot as plt

            highlight_graph(G_visual, clusters, cmap=plt.cm.gist_ncar)
            plt.savefig(name_core + ".png")
        except ImportError:
            print("Warning: matplotlib is required for visualization (-v option). Please install it.")
        except nx.NetworkXUnfeasible:
            print("Warning: Graph layout failed. Visualization may not be accurate.")
        except Exception as e:
            print(f"Error during visualization: {e}")

    print(("Mincut results file: " + output_file))


if __name__ == "__main__":
    import doctest

    doctest.testmod()
    main()
