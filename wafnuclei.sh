#!/bin/bash

rm -f domains.txt
rm -f results.txt

# ANSI color codes
green='\033[0;32m'
reset='\033[0m'

# Echo "Running Subfinder" in green
echo -e "${green}Running Subfinder${reset}"
subfinder -d $domain -all -silent -o domains.txt

# Define input and output files
input_file="domains.txt"
output_file="nowaf.txt"

# Remove output file if it already exists
rm -f "$output_file"

echo -e "${green}Running WafW00f${reset}"
# Loop through each domain in the input file
while IFS= read -r domain; do
    # Run wafw00f on the domain and check if WAF detected
    if wafw00f "$domain" | grep -qi "No WAF detected by the generic detection"; then
        # If no WAF detected, save the domain to the output file
        echo "$domain" >> "$output_file"
    fi
done < "$input_file"

echo -e "${green}Subdomains without WAF protection${reset}"
cat nowaf.txt | notify -bulk -silent -pc provider-config.yaml

echo -e "${green}Running Nuclei${reset}"
# Run nuclei on domains without WAF
nuclei -l nowaf.txt -s critical,high,medium,low -fr -iserver uxxbakcpqehrnrfowwuxguhai0imvotcr.oast.fun -o results.txt | notify -bulk -silent -pc provider-config.yaml
