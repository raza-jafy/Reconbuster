#!/bin/bash

subfinder -dL $domain -all -silent -o domains.txt

# Define input and output files
input_file="domains.txt"
output_file="nowaf.txt"

# Remove output file if it already exists
rm -f "$input_file"
rm -f "$output_file"

# Loop through each domain in the input file
while IFS= read -r domain; do
    # Run wafw00f on the domain and check if WAF detected
    if wafw00f "$domain" | grep -qi "No WAF detected"; then
        # If no WAF detected, save the domain to the output file
        echo "$domain" >> "$output_file"
    fi
done < "$input_file"

# Run nuclei on domains without WAF
nuclei -l nowaf.txt -s critical,high,medium,low -fr -iserver uxxbakcpqehrnrfowwuxguhai0imvotcr.oast.fun -o results.txt | notify -silent -pc provider-config.yaml 
