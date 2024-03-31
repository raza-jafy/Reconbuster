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
        nuclei_output=$(nuclei -u "$domain" -s critical,high,medium,low -rl 3 -c)
        
        # Check if nuclei found any vulnerabilities
        if [[ -n "$nuclei_output" ]]; then
            echo "Nuclei found vulnerabilities for $domain"
            
            # Send the nuclei output to Discord using notify
            notify -d "Nuclei found vulnerabilities for $domain" -m "$nuclei_output" -t https://discord.com/api/webhooks/1223901339461877812/VdXtTYVcbTSJmfT2_ILMzvQAhndObPGw4xt1rk6FF_tiRIMrAep35aP78JehOjIDzOC5
        else
            echo "Nuclei found no vulnerabilities for $domain"
        fi
    else
        echo "WAF detected for $domain"
    fi

done < "$input_file"
