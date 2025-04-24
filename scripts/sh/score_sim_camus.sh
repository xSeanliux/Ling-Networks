#!/bin/bash

# Default value
SUFFIX=""
SETTING="high"
MAX_EDGES=3
MAX_TREES=16
MAX_REPLICAS=1

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--factor) FACTOR="$2"; shift 2 ;;
    -x|--suffix) SUFFIX="$2"; shift 2 ;; #TODO incorporate this
    -s|--setting) SETTING="$2"; shift 2 ;;
    -m|--method) METHOD="$2"; shift 2 ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check required arguments
if [[ -z "$FACTOR" ||  -z "$METHOD" ]]; then
  echo "Usage: $0 -f <factor> -s <setting> -m <method> [-x <suffix>]"
  exit 1
fi

# Print the parsed values (or use them as needed)
echo "Factor: $FACTOR"
echo "Suffix: $SUFFIX"
echo "Setting: $SETTING"
echo "Method: $METHOD"

# set $SUFFIX to be flag if not empty
[[ -n "$SUFFIX" ]] && SUFFIX="-$SUFFIX"
RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)


FOLDER=$TALLIS/Ling-Networks/outputs/inference_outputs-$FACTOR/$SETTING"_borrowing"/"$METHOD"/CAMUS
OUTPUT_PATH=$FOLDER/underlyingtree_scores.csv
echo edges,tree,replica,fn,fp,cd,js > $OUTPUT_PATH

for INFERRED_NETWORK_PATH in $FOLDER/networks/*.nwk; do
    BASENAME=$(basename $INFERRED_NETWORK_PATH)
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

    echo $EDGENUM,$TREENUM,$REPLNUM,$(python3 $TALLIS/Network-FN-FP/getUnderlyingTreeCladeDifference.py\
                --reference $TRUE_NETWORK_PATH\
                --inferred $INFERRED_NETWORK_PATH\
                | awk -F'=' '{print $2}' | paste -sd ',' -)\
                >> $OUTPUT_PATH

 

      # Skip if no files match the pattern
#   [[ -e "$file" ]] || continue
  
#   echo "Processing: $file"
  # Your logic here
done