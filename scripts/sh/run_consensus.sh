#!/bin/bash
#SBATCH --output=SLURM_OUT/R-%x.%j.out
#SBATCH --error=SLURM_OUT/R-%x.%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --job-name=NETWORK-CONSENSUS
#SBATCH --partition=eng-instruction
#SBATCH --mem=256000
#SBATCH --account=25sp-cs581a-eng
ROOT=$TALLIS/Ling-Networks/outputs

if [[ -z "$ROOT" ]]; then
    echo "Usage: $0 ROOT_FOLDER PYTHON_SCRIPT"
    exit 1
fi

# # Find all matching files with .trees extension under GA directories
# find "$ROOT" -type f -path "*/*/GA/trees1/*.trees" | while read -r FILE; do
#     # Replace /trees1/ with /trees/
#     CONSPATH="${FILE/\/trees1\//\/trees\/}"

#     # Replace .trees with .nwk
#     CONSFILE="${CONSPATH%.trees}-mcc_consensus.nwk"

#     if [[ ! -s "$CONSFILEFILE" ]]; then
#         echo FILE=$FILE
#         echo CONSFILE=$CONSFILE
#         Rscript $TALLIS/QuartetMethods/scripts/R/consensusTree.R\
#             -i $FILE\
#             -m 4\
#             -p 1\
#             -o $CONSFILE\
#             --discard 50
#     else
#         echo "Skipping $FILE (output exists and is non-empty)"
#     fi
# done

# find "$ROOT" -type f -path "*/*/MP4/trees/*.trees" | while read -r FILE; do
#     # Replace /trees1/ with /trees/

#     # Replace .trees with .nwk
#     echo FILE IS $FILE
#     CONSFILE="${FILE%.trees}-greedy_consensus.nwk"

#     if [[ ! -s "$CONSFILEFILE" ]]; then
#         echo FILE=$FILE
#         echo CONSFILE=$CONSFILE
#         Rscript $TALLIS/QuartetMethods/scripts/R/consensusTree.R\
#             -i $FILE\
#             -m 2\
#             -p 1\
#             -o $CONSFILE\
#             --discard 0
#     else
#         echo "Skipping $FILE (output exists and is non-empty)"
#     fi
# done


find "$ROOT" -type f -path "*/*/ASTRAL\(9,5\)/trees/*.tree" | while read -r FILE; do
    # Replace /trees1/ with /trees/

    # Replace .trees with .nwk
    echo FILE IS $FILE
    CONSFILE="${FILE%.tree}-output.nwk"
    echo CONSFILE IS $CONSFILE

    cp "$FILE" "$CONSFILE"
done