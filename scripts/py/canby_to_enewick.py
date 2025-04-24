import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from lib.eNewick import get_network


import argparse

def process_path(path):
    with open(path, 'r') as f:
        contents = f.read()
    result = get_network(contents)
    print(result)

def main():
    parser = argparse.ArgumentParser(description="Process a network in Canby format and output it in extended newick format.")
    parser.add_argument('filepath', help="Path to the input file")
    args = parser.parse_args()

    process_path(args.filepath)

if __name__ == "__main__":
    main()