#!/bin/bash
shopt -s expand_aliases # expand alias so that mb works
TREECOUNT=16
EDGECOUNT=3
SUFFIX=""
REPLICA_COUNT=1  # a number from 1 to 4
OS_TYPE='RedHat' # RedHat / OSX
DO_ASTRAL=false  # a(stral)
DO_MP4=false     # p(arsimony)
DO_GA=false      # g(ray & atkinson)
DO_COVARION=false   # c(ovarion)

# ASTRAL modes
QT_MODE=1
BP_MODE=5

FACTORS=(1.0 2.0 4.0) # f
SETTINGS=(mod modhigh high) # s 
RUNID=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo) # random string so that runs don't use the same name (i.e. for temp files)
MB_EXEC=$TALLIS/bin/bin/mb
while getopts 'acpgq:b:ms:f:x:' o; do 
    echo $o' '$OPTARG
    case $o in 
        a) DO_ASTRAL=true;;
        c) DO_COVARION=true;;
        p) DO_MP4=true;;
        g) DO_GA=true;;
        q) QT_MODE=$OPTARG;;
        b) BP_MODE=$OPTARG;;
        x) SUFFIX=$OPTARG;;
        f) 
        if [[ ${FACTORS[@]} =~ $OPTARG ]]; then  
            echo "FOUND FACTOR "$OPTARG 
            FACTORS=($OPTARG)
        else 
            echo "FACTOR NOT FOUND. USING ALL"
        fi;;
        s)
        if [[ ${SETTINGS[@]} =~ $OPTARG ]]; then  
            echo "FOUND SETTING "$OPTARG 
            SETTINGS=($OPTARG)
        else 
            echo "SETTING NOT FOUND. USING ALL"
        fi;;
        *) echo "Unknown argument: "$o
    esac
done 

echo "SUFFIX IS "$SUFFIX

if [[ -z "$SUFFIX" ]]; then 
    SUFFIX=""
else
    SUFFIX=-$SUFFIX
fi

echo "ASTRAL: $DO_ASTRAL"
if $DO_ASTRAL; then 
    echo "QT MODE: $QT_MODE, BP MODE: $BP_MODE"
fi
echo "MP4: $DO_MP4"
echo "COVARION: $DO_COVARION"
echo "GA: $DO_GA"
echo "Settings:"${SETTINGS[@]}
echo "Factors:"${FACTORS[@]}

if [[ $OS_TYPE = "RedHat" ]]; then 
    PAUP_PATH=$TALLIS/QuartetMethods/scripts/bin/paup4a168_centos64
    chmod a+x $PAUP_PATH
elif [[ $OS_TYPE = "OSX" ]]; then 
    PAUP_PATH=$TALLIS/QuartetMethods/scripts/bin/paup
else 
    echo "PAUP_PATH could not be set (OSTYPE ="$OSTYPE" may be invalid )"
fi

for f in ${FACTORS[@]}; do
    echo "RUNNING "$f
    DATASET=$TALLIS/Ling-Networks/example/simulated-rooted-network-$f$SUFFIX
    for setting in ${SETTINGS[@]}; do
        TREEOUTPUT=$TALLIS/Ling-Networks/outputs/inference_outputs-$f$SUFFIX/$setting'_borrowing'
        ASTRAL_VARIANT=ASTRAL\($QT_MODE,$BP_MODE\)
        # initialise tree output space
        mkdir -p $TREEOUTPUT
        if $DO_ASTRAL; then
            mkdir -p $TREEOUTPUT/$ASTRAL_VARIANT/logs
            mkdir -p $TREEOUTPUT/$ASTRAL_VARIANT/trees
        fi
        if $DO_MP4; then
            mkdir -p $TREEOUTPUT/MP4/trees
            mkdir -p $TREEOUTPUT/MP4/scores
        fi
        if $DO_COVARION; then
            mkdir -p $TREEOUTPUT/COV/trees
            mkdir -p $TREEOUTPUT/COV/scores
        fi
        if $DO_GA; then
            mkdir -p $TREEOUTPUT/GA/trees
            mkdir -p $TREEOUTPUT/GA/trees1
            mkdir -p $TREEOUTPUT/GA/scores
        fi
        CSVS=$DATASET/$setting'_borrowing'/
        echo $CSVS
        for ((e=1;e<=$EDGECOUNT;e++)); do
            for ((i=1;i<=$TREECOUNT;i++)); do # tree number
                for ((r=1;r<=$REPLICA_COUNT;r++)); do # rep number
                    pattern="sim_net$e-$i""_"$r".csv"
                    for FILE in $CSVS/*; do
                        if [[ $FILE =~ $pattern ]]; then
                            id=$setting$e-_$i'_'$r
                            uid=$(uuidgen)
                            echo "Factor: $f; ID = $id, edgecount = $e: target is tree $i"
                            # generate quartets
                            if $DO_COVARION; then 
                                if ! test -f $TREEOUTPUT/COV/trees/$id.tree; then 
                                    # generate new config file
                                    bash $TALLIS/QuartetMethods/scripts/sh/runCOV.sh\
                                        --runid $RUNID\
                                        --input $FILE\
                                        --output $TREEOUTPUT\
                                        --name $id
                                    rm -rf $RUN_NAME'_path_sampling'
                                else
                                    echo "skipping "$id
                                fi
                            fi
                            if $DO_GA; then 
                                if ! test -f $TREEOUTPUT/GA/trees1/$id.trees; then 
                                    > ~/scratch/tmp_mb_$RUNID.nex
                                    Rscript $TALLIS/QuartetMethods/scripts/R/commandLineNex.R -H $RUNID -f $FILE -o ~/scratch/tmp_mb_$RUNID.nex --resolve-poly 4 --morph-weight 1.0  > /dev/null 2> /dev/null
                                    echo "✅ GA nexus files"
                                    cat ~/scratch/tmp_mb_$RUNID.nex 
                                    $MB_EXEC ~/scratch/tmp_mb_$RUNID.nex > /dev/null 2> /dev/null # > tmp_mb_out_$RUNID.txt 2> tmp_mb_log_$RUNID.txt
                                    echo "✅ GA sampling"
                                    mv Bayes_out_$RUNID.t $TREEOUTPUT/GA/trees1/$id.trees 
                                    mv Bayes_out_$RUNID.con.tre $TREEOUTPUT/GA/trees/$id.trees
                                    rm Bayes_out_$RUNID.* # tmp_mb*
                                else
                                    echo "skipping "$id
                                fi
                            fi
                            if $DO_MP4; then 
                                if ! test -f $TREEOUTPUT/MP4/trees/$id.trees; then # You can run this multiple times to continue where you left off
                                    >~/scratch/tmp_mp4_$RUNID.nex
                                    Rscript $TALLIS/QuartetMethods/scripts/R/commandLineNex.R -H $RUNID -f $FILE -o ~/scratch/tmp_mp4_$RUNID.nex -p 3 -m 1.0 > /dev/null 2> /dev/null
                                    echo "✅ MP4 nexus files"
                                    $PAUP_PATH -n ~/scratch/tmp_mp4_$RUNID.nex > /dev/null 2> /dev/null
                                    mv ~/scratch/paup_out_$RUNID.trees $TREEOUTPUT/MP4/trees/$id.trees # If we run lots of instances of this script in parallel, paup_out might be overwritten so we can't have that
                                    mv ~/scratch/paup_out_$RUNID.scores $TREEOUTPUT/MP4/scores/$id.scores
                                    echo "✅ MP4 tree inference" 
                                else 
                                    echo "Skipping "$id
                                fi
                            fi
                            if $DO_ASTRAL; then # run ASTRAL 
                                if ! test -f $TREEOUTPUT/$ASTRAL_VARIANT/trees/$id.tre; then
                                    $TALLIS/QuartetMethods/scripts/sh/runASTRAL.sh\
                                        -H $RUNID\
                                        -i $FILE\
                                        -o $TREEOUTPUT\
                                        -n $id\
                                        -q $QT_MODE\
                                        -b $BP_MODE

                                    rm ~/scratch/tmp_quartet_$RUNID.txt
                                    rm ~/scratch/tmp_bipartitions_$RUNID.bootstrap.trees
                                else 
                                    echo "Heuristic ASTRAL: Skipping "$id
                                fi
                            fi
                        fi
                    done
                done
            done
        done
    done
done
