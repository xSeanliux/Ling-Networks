#!/bin/bash

# Default values (optional)
factor=""
suffix=""
setting="high"
MAX_EDGES=3
MAX_TREES=16
MAX_REPLICAS=1

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -f|--factor)
            factor="$2"
            shift 2
            ;;
        -x|--suffix)
            suffix="$2"
            shift 2
            ;;
        -s|--setting)
            setting="$2"
            shift 2
            ;;
        --) # end of all options
            shift
            break
            ;;
        -*|--*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *) # No more options
            break
            ;;
    esac
done

# Example: Print the values
echo "Factor: $factor"
echo "Suffix: $suffix"
echo "Setting: $setting"


OUTPUT_FOLDER=$TALLIS/Ling-Networks/outputs/inference_outputs-$factor/$setting"_borrowing"/TRUE-CAMUS
echo edges,tree,replica,fn,fp,cd,js > $OUTPUT_FOLDER/scores.csv

for ((edges=1;edges<=$MAX_EDGES;edges++)); do 
    for ((treenum=1;treenum<=$MAX_TREES;treenum++)); do 
        for ((replica=1;replica<=$MAX_REPLICAS;replica++)); do 
            echo $edges Edges, Tree \# $treenum
        
            RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo) # random string so that runs don't use the same name (i.e. for temp files)

            TRUE_NETWORK_PATH=$TALLIS/Ling-Networks/example/rooted-networks-enewick/net$edges-$treenum.txt
            # echo ';' >> $TRUE_TREE_PATH
            INFERRED_NETWORK_PATH=$OUTPUT_FOLDER/networks/$setting$edges"-_"$treenum"_"$replica.nwk
            echo $edges,$treenum,$replica,$(python3 $TALLIS/Network-FN-FP/getCladeDifference.py\
                --reference $TRUE_NETWORK_PATH\
                --inferred $INFERRED_NETWORK_PATH\
                | awk -F'=' '{print $2}' | paste -sd ',' -)\
                >> $OUTPUT_FOLDER/scores.csv

      
        done 
    done 
done 
