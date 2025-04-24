#!/bin/bash

# Usage: ./run_batch.sh input_folder output_folder python_file.py

INPUT="$1"
OUTPUT="$2"

# Check that all arguments are provided
if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
    echo "Usage: $0 INPUT_FOLDER OUTPUT_FOLDER PYTHON_FILE"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT"

# Loop through each file in the input directory
for FILE in "$INPUT"/*; do
    BASENAME=$(basename "$FILE")
    echo $FILE
    python /projects/illinois/eng/cs/warnow/zxliu2/Ling-Networks/scripts/py/canby_to_enewick.py "$FILE" > "$OUTPUT/$BASENAME"
done
