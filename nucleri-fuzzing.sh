#!/bin/bash

excluded_extentions="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -h|--help)
            display_help
            ;;
        -d|--domain)
            domain="$2"
            shift
            shift
            ;;
        -f|--file)
            filename="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Step 3: Get the vulnerable parameters based on user input
if [ -n "$domain" ]; then
    echo "Running ParamSpider on $domain"
    paramspider -d "$domain" --exclude "$excluded_extentions" --level high --quiet -o "$domain.txt"
elif [ -n "$filename" ]; then
    echo "Running ParamSpider on URLs from $filename"
    while IFS= read -r line; do
        paramspider -d "$line" --exclude "$excluded_extentions" --level high --quiet -o "$line.txt"
        cat "$line.txt" >> "$output_file"  # Append to the combined output file
    done < "$filename"
fi

# Step 4: Check whether URLs were collected or not
if [ ! -s "$domain.txt" ] && [ ! -s "$output_file" ]; then
    echo "No URLs Found. Exiting..."
    exit 1
fi

# Step 5: Run the Nuclei Fuzzing templates on the collected URLs
echo "Running Nuclei on collected URLs"
if [ -n "$domain" ]; then
    sort "$domain.txt" | uniq | tee "$domain.txt" | httpx -silent -mc 200,301,302 | nuclei -t "$home_dir/fuzzing-templates" -fuzz -debug-req -rl 05 | notiffy
elif [ -n "$filename" ]; then
    sort "$output_file" | uniq | tee "$output_file" | httpx -silent -mc 200,301,302 | nuclei -t "$home_dir/fuzzing-templates" -fuzz -debug-req -rl 05 | notiffy
fi

# Step 6: End with a general message as the scan is completed
echo "Scan is completed - Happy Fuzzing"
