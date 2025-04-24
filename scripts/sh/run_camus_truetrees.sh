#!/bin/bash
#SBATCH --output=SLURM_OUT/R-%x.%j.out
#SBATCH --error=SLURM_OUT/R-%x.%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --partition=eng-instruction
#SBATCH --account=25sp-cs581a-eng
source ~/.bashrc 
cd $TALLIS
conda deactivate
source activate phylo
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

for ((edges=1;edges<=$MAX_EDGES;edges++)); do 
  for ((treenum=1;treenum<=$MAX_TREES;treenum++)); do 
    for ((replica=1;replica<=$MAX_REPLICAS;replica++)); do 
        echo $edges Edges, Tree \# $treenum
    
        RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo) # random string so that runs don't use the same name (i.e. for temp files)

        CSV_FILE=$TALLIS/Ling-Networks/example/simulated-rooted-network-$factor/$setting'_borrowing'/sim_net$edges-$treenum'_'$replica.csv
        TRUE_NETWORK_PATH=/projects/illinois/eng/cs/warnow/zxliu2/Ling-Networks/example/rooted-networks/net$edges-$treenum.txt
        TRUE_TREE_PATH=~/scratch/true_tree_$RUNID.nwk

        IFS= read -r firstline < $TRUE_NETWORK_PATH
        echo "${firstline};" > $TRUE_TREE_PATH
        # echo ';' >> $TRUE_TREE_PATH


        OUTPUT_FOLDER=$TALLIS/Ling-Networks/outputs/inference_outputs-$factor/$setting"_borrowing"/TRUE-CAMUS
        mkdir -p $OUTPUT_FOLDER


        NAME=$setting$edges"-_"$treenum"_"$replica
        if ! test -s $OUTPUT_FOLDER/networks/$NAME.nwk; then 
            bash $TALLIS/Ling-Networks/scripts/sh/run_camus.sh\
                --data $CSV_FILE\
                --tree $TRUE_TREE_PATH\
                --output_folder $OUTPUT_FOLDER\
                --name $NAME\
                --quartet 9
        else 
            echo SKIPPING $NAME.nwk
        fi
    done 
  done 
done 
