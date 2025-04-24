#!/bin/bash

# Default value
MAX_EDGES=3
MAX_TREES=16
MAX_REPLICAS=1


# set $SUFFIX to be flag if not empty
[[ -n "$SUFFIX" ]] && SUFFIX="-$SUFFIX"
RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)


FOLDER=$TALLIS/Ling-Networks/outputs/inference_outputs-$FACTOR/$SETTING"_borrowing"/"$METHOD"/
echo edges,tree,replica,fn,fp,cd,js >$FOLDER/scores.csv

for INFERRED_TREE_PATH in $FOLDER/trees/*.nwk; do
    BASENAME=$(basename $INFERRED_TREE_PATH)
    echo $BASENAME
    if [[ "$BASENAME" =~ ^high([0-9])-_([0-9]+)_([0-9]+) ]]; then
        EDGENUM="${BASH_REMATCH[1]}"
        TREENUM="${BASH_REMATCH[2]}"
        REPLNUM="${BASH_REMATCH[3]}"
        echo "Tree no $TREENUM, replica $REPLNUM, has $EDGENUM extra edges."
    else
        echo "No match. Exiting."
        exit 0
    fi

    TRUE_NETWORK_PATH=$TALLIS/Ling-Networks/example/rooted-networks-enewick/net$EDGENUM-$TREENUM.txt

    echo $INFERRED_NETWORK_PATH

    echo $EDGENUM,$TREENUM,$REPLNUM,$(python3 $TALLIS/Network-FN-FP/getCladeDifference.py\
                --reference $TRUE_NETWORK_PATH\
                --inferred $INFERRED_TREE_PATH\
                | awk -F'=' '{print $2}' | paste -sd ',' -)\
                >> $FOLDER/scores.csv

 

      # Skip if no files match the pattern
#   [[ -e "$file" ]] || continue
  
#   echo "Processing: $file"
  # Your logic here
done