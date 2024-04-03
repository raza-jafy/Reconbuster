#!/bin/bash

# Array to hold the wordlist filenames
wordlists=("onelistforallaa" "onelistforallab" "onelistforallac" "onelistforallad" "onelistforallae" "onelistforallaf" "onelistforallag" "onelistforallah" "onelistforallai" "onelistforallaj")

# Function to run gobuster on domains.txt with each wordlist
run_gobuster() {
    local domain_file="$1"
    for wordlist in "${wordlists[@]}"; do
        echo "Running FFUF on $domain_file with wordlist: $wordlist.txt"
        while IFS= read -r domain; do
            echo "Domain: $domain" | notify -silent -pc provider-config.yaml
            ffuf -w "$wordlist" -u "$domain_file" -ac -mc 200,301,403 -t 20 -se -o "$domain_file" | notify -silent -pc provider-config.yaml
        done < "$domain_file"
    done
}

# Call the function with the domains.txt file
run_gobuster "domains.txt"
