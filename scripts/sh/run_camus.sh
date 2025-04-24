#!/bin/bash

# Default values
DATA=""
TREE=""
OUTPUT_FOLDER=""
QUARTET_MODE=9
OUTGROUP=og
OUT_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--data) DATA="$2"; shift 2 ;;
    -q|--quartet) QUARTET_MODE="$2"; shift 2 ;;
    -t|--tree) TREE="$2"; shift 2 ;;
    -o|--output_folder) OUTPUT_FOLDER="$2"; shift 2 ;;
    -O|--outgroup) OUTGROUP="$2"; shift 2 ;; 
    -n|--name) OUT_NAME="$2"; shift 2 ;; 
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Check required arguments
if [[ -z $DATA || -z $TREE || -z $OUTPUT_FOLDER ]]; then
  echo "Usage: $0 -d <data_path> -t <tree_path> -o <output_folder>"
  exit 1
fi

# Ensure output folder exists
mkdir -p "$OUTPUT_FOLDER"
mkdir -p "$OUTPUT_FOLDER"/logs
mkdir -p "$OUTPUT_FOLDER"/networks

# ROOT 
RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo) # random string so that runs don't use the same name (i.e. for temp files)
QUARTET_FILE=~/scratch/tmp_quartets_$RUNID.nexus
ROOTED_TREE_FILE=~/scratch/tmp_rootedtree_$RUNID.nexus

python3 $TALLIS/QuartetMethods/scripts/py/printQuartets.py\
    -i $DATA\
    -q $QUARTET_MODE\
    > $QUARTET_FILE
echo Quartet generation complete. $(cat $QUARTET_FILE | wc -l) quartets generated.

python3 $TALLIS/Ling-Networks/scripts/py/root_tree.py\
    --tree $TREE\
    --output $ROOTED_TREE_FILE\
    --outgroup $OUTGROUP
echo Rooting complete. 
echo Rooted tree looks like $(cat $ROOTED_TREE_FILE)


# Root 

$TALLIS/camus/camus infer $ROOTED_TREE_FILE $QUARTET_FILE\
    > $OUTPUT_FOLDER/networks/$OUT_NAME.nwk\
    2> $OUTPUT_FOLDER/logs/$OUT_NAME.log
echo CAMUS finished. Saving to $OUTPUT_FOLDER/trees/$OUT_NAME.nwk 

