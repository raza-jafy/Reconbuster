#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Assign input file name to variable
INPUT_FILE="$1"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File $INPUT_FILE not found."
    exit 1
fi

# Define the wordlist

WORDLIST="/root/Desktop/bounty/confidential/SecLists/Discovery/Web-Content/raft-large-directories-lowercase.txt"

# Define the patterns to fuzz
PATTERNS=("/.FUZZ" "/-FUZZ" "/~FUZZ" "/../FUZZ" "/_FUZZ")

# Loop through each URL in the input file
while IFS= read -r URL; do
    echo "Fuzzing URL: $URL"
    
    # Loop through each pattern
    for PATTERN in "${PATTERNS[@]}"; do
        echo "Fuzzing pattern: $PATTERN"
        
        #Run ffuf with the current pattern and save output to a temporary file
        OUTPUT_FILE=$(mktemp)
        ffuf -u "$URL$PATTERN" -w "$WORDLIST" -mc 200,403 -ac -recursion -recursion-depth 2 -t 3| notify -silent -id Confidential-Exif1, Confidential-Exif2 | tee "$OUTPUT_FILE"
        
        # Remove temporary output file
        rm "$OUTPUT_FILE"
        
        echo "----------------------------------------------"
    done
    
    echo "=============================================="
done < "$INPUT_FILE"
