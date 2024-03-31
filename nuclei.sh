#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Assign input file name to a variable
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File $input_file not found."
    exit 1
fi

# Loop through each domain in the input file
while IFS= read -r domain; do
    echo "Processing domain: $domain"
    
    # Run wafw00f on the domain
    waf_output=$(wafw00f "$domain")
    
    # Check if "No WAF detected by the generic detection" is in the output
    if [[ "$waf_output" == *"No WAF detected by the generic detection"* ]]; then
        echo "No WAF detected for $domain"
        
        # Run nuclei on the domain
        nuclei -u "$domain" -as -s critical,high,medium,low -rl 3 -c 2 && notify -silent -id Confidential-Exif1, Confidential-Exif2
    else
        echo "WAF detected for $domain"
    fi

done < "$input_file"
