#!/bin/bash
echo "Starting run_parallel.sh"
# FACTORS=(1.0 2.0 4.0 8.0)
FACTORS=(1.0 2.0 4.0)
METHODS=(MP4 COV "ASTRAL\(10,5\)" GA "ASTRAL\(9,5\)")
SUFFIXES=('""')
SETTINGS=(high)
TIMES=1

# FACTORS=(1.0 4.0 8.0)
# MORPHS=(true false)
# METHODS=(c)
# SETTINGS=(mod high)
# TIMES=8

for m in ${METHODS[@]}; do
    for SUFFIX in "${SUFFIXES[@]}"; do
        echo "FOUND SUF" $SUFFIX
        if [[ -z "$SUFFIX" ]]; then 
            SUFFIX_CMD=""
        else
            SUFFIX_CMD="-x $SUFFIX"
        fi
        for setting in ${SETTINGS[@]}; do
            for f in ${FACTORS[@]}; do
                LASTJOB=""
                for ((i=1;i<=$TIMES;i++)); do
                    if [ $i -eq 1 ]; then 
                        RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo) # random string so that runs don't use the same name (i.e. for temp files)
                        FILENAME=~/scratch/inference-$f-$SUFFIX-$m-$DO_MORPH-$setting-$RUNID.sbatch
                        echo "#!/bin/bash
#SBATCH --output=SLURM_OUT/R-%x.%j.out
#SBATCH --error=SLURM_OUT/R-%x.%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --partition=eng-instruction
#SBATCH --mem=256000
#SBATCH --account=25sp-cs581a-eng
#SBATCH --job-name=$m-$SUFFIX-$f-$setting-CAMUS
source ~/.bashrc 
cd $TALLIS
conda deactivate
source activate phylo
time bash Ling-Networks/scripts/sh/run_sim_camus.sh --factor $f --setting $setting --method $m $SUFFIX_CMD" > $FILENAME
                        LASTJOB=`sbatch $FILENAME | cut -f 4 -d " "`
                        echo $FILENAME
                        echo "submitting m=$m f=$f morph=$DO_MORPH setting=$setting lastjob = $LASTJOB"
                    else
                        LASTJOB=`sbatch --dependency=afterany:$LASTJOB $FILENAME | cut -f 4 -d " "`
                        echo "submitting m=$m f=$f morph=$DO_MORPH setting=$setting lastjob = $LASTJOB"
                    fi
                done
            done
        done
    done
done