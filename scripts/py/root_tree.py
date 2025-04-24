#!/usr/bin/env python3

import argparse
import treeswift
import sys
import re

def main():
    parser = argparse.ArgumentParser(description="Process tree and outgroup inputs. Roots tree at outgroup and arbitrarily resolves all polytomies.")
    
    parser.add_argument('-t', '--tree', required=True, help='Path to the tree file')
    parser.add_argument('-f', '--format', required=False, help='Format of the tree', default='newick')
    parser.add_argument('-o', '--output', required=False, help='Path to the output tree file', default=None)
    parser.add_argument('-O', '--outgroup', required=True, help='Name of the outgroup')

    args = parser.parse_args()

    # Access the arguments
    tree_path = args.tree
    outgroup = args.outgroup


    tree = treeswift.read_tree(
        tree_path, 
        schema=args.format
    )
    tree.resolve_polytomies()
    for node in tree.root.traverse_inorder():
        node.set_edge_length(0.5)
        if not node.is_leaf():
            node.set_label("")

    outgroup_node = tree.find_node(label=outgroup)
    tree.reroot(node=outgroup_node, length=0.1)
    old_root_node = tree.find_node(label="ROOT")
    if old_root_node is not None:
        old_root_node.contract()
    tree.suppress_unifurcations()
    newick_string = tree.newick()
    if newick_string.startswith('[&R]'):
        newick_string = newick_string[4:].strip()
    newick_string = re.sub(r':[01](\.\d+)?', '', newick_string) # remove branch lengths
    out_stream = open(args.output, 'w') if args.output else sys.stdout

    out_stream.write(newick_string)

if __name__ == '__main__':
    main()
