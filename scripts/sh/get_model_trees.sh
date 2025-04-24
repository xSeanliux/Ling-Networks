#!/bin/bash

# Usage: ./script.sh input_folder output_folder

INPUT="$1"
OUTPUT="$2"

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT"

# Process each file in the input folder
for FILE in "$INPUT"/*; do
    # Skip if not a regular file
    BASENAME="$(basename "$FILE")"
    [ -f "$FILE" ] || continue
    if [[ "$BASENAME" =~ ^net([0-9])-([0-9]+) ]]; then
        EDGENUM="${BASH_REMATCH[1]}"
        TREENUM="${BASH_REMATCH[2]}"

        [[ $TREENUM -gt 16 || $REPLNUM -gt 1 ]] && continue
        echo "Tree no $TREENUM, replica $REPLNUM, has $EDGENUM extra edges."
    else
        echo "No match for $BASENAME Exiting."
        exit 0
    fi

    # Extract filename without path or extension
    NAME="${BASENAME%.*}"

    # Create new output filename with .nwk extension

    # Extract the first line and write to new file
    MODELTREE=$(head -n 1 "$FILE")
    NEWFILE="$OUTPUT/high$EDGENUM-_$TREENUM""_1.nwk"
    echo "$MODELTREE;" > "$NEWFILE"
done