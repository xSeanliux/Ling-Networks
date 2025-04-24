#!/bin/bash

# Default value
SUFFIX=""
SETTING="high"

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
if [[ -z "$FACTOR" || -z "$SETTING" || -z "$METHOD" ]]; then
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

FOLDER=$TALLIS/Ling-Networks/outputs/inference_outputs-$FACTOR/$SETTING"_borrowing"/"$METHOD"

for FILE in $FOLDER/trees/*.nwk; do
    BASENAME=$(basename $FILE)
    echo $BASENAME
    if [[ "$BASENAME" =~ ^$SETTING([0-9])-_?([0-9]+)_ ]]; then
        TREENUM="${BASH_REMATCH[2]}"
        EDGENUM="${BASH_REMATCH[1]}"
        echo "Tree no $TREENUM, has $EDGENUM extra edges."
    else
        echo "No match. Exiting."
        exit 0
    fi

    $TALLIS/Ling-Networks/scripts/sh/run_camus.sh\
        --data $TALLIS/Ling-Networks/example/simulated-rooted-network-$FACTOR/$SETTING"_borrowing"/sim_net$EDGENUM-$TREENUM"_1.csv"\
        --tree "$FILE"\
        --output_folder "$FOLDER"/CAMUS\
        --name "${BASENAME%.nwk}"

      # Skip if no files match the pattern
#   [[ -e "$file" ]] || continue
  
#   echo "Processing: $file"
  # Your logic here
done