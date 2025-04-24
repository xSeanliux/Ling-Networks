# Converts a network in Canby etal's format to standard extended newick format. 
# Canby etal's fromat has the underlying tree in the first line
# and the following lines have 4 semicolon-separated strings
# the first and second of which are clades in the tree, meaning the contact edge is between the edges above the two clades. 
# the third and fourth strings represent numerical parameters of the edge, which are unimportant for the tree topology. 

import phylonetwork as pn
import regex as re
from functools import partial


def replace_newick(
    newick_tree,
    st1,
    st2, 
    id1,
    id2,
) -> str:
    newick_tree = newick_tree.replace(
        f"({st1},", 
        f"(({st1},#H{id1})#H{id2},"
    )
    newick_tree = newick_tree.replace(
        f",{st1})", 
        f",({st1},#H{id1})#H{id2})"
    )
    newick_tree = newick_tree.replace(
        f"({st2},",
        f"(({st2},#H{id2})#H{id1},"
    )
    newick_tree = newick_tree.replace(
        f",{st2})",
        f",({st2},#H{id2})#H{id1})"
    )
    return newick_tree

def get_network(input_str):
    lines = input_str.split('\n') 

    newick_tree, *extra_edges = lines

    if newick_tree[-1] != ';':
        newick_tree += ';'

    # remove edge labels
    newick_tree = re.sub(pattern=r':\d.\d+', repl="", string=newick_tree)
    extra_edges = list(map(
        lambda x: re.sub(pattern = r':\d.\d+', repl="", string=x),
        extra_edges
    ))
    to_add_edges = []
    for edgestring in extra_edges:
        st1, st2, t, *_ = edgestring.split(';')
        t = float(t)
        to_add_edges.append((t, st1, st2))
    to_add_edges = sorted(to_add_edges, key = lambda x: x[0], reverse=True) # sort in decreasing time
    # print(newick_tree)
    # print(extra_edges)

    for i in range(len(to_add_edges)):
        id1, id2 = 2 * i + 1, 2 * i + 2
        # print('ei is ', edge_input)
        t, st1, st2 = to_add_edges[i]
        newick_tree = replace_newick(
            newick_tree,
            st1,
            st2,
            id1,
            id2,
        )
        extra_edges = list(map(
            lambda x: replace_newick(newick_tree=x, st1=st1, st2=st2, id1=id1, id2=id2),
            extra_edges
        ))
        # print(extra_edges)
    
    return newick_tree