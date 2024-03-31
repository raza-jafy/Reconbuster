#!/bin/bash

# Download the list of urls and save it to domains.txt
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/domains.txt" > domains.txt

# Run gau on the domains to collect urls
cat domains.txt | gau --subs --o urls.txt 

# Define array of file extensions to filter
file_extensions=("jpeg" "docx" "xlsx" "doc" "ppt" "pptx" "img" "png" "svg" "rtf" "odt" "pdf")

# Loop through each file extension and filter urls
for ext in "${file_extensions[@]}"; do
    grep -E "\.${ext}$" urls.txt >> filtered_urls.txt
done

# Loop through the filtered urls and run exiftool
while IFS= read -r url; do
    # Download the file
    curl -s "$url" -o temp_file
    
    # Run exiftool
    exif_output=$(exiftool temp_file)
    
    # Check if exiftool identifies Latitude, Longitude, GPSLocation, or Password
    if grep -qE "Latitude|Longitude|GPSLocation|comments|gpslocation|passwords|password|URL" <<< "$exif_output"; then
        # Send results to notify
        notify -mf "Exiftool identified sensitive data in: $url" -silent -id Confidential-Exif1,Confidential-Exif2
    fi
    
    # Clean up temporary file
    rm temp_file
done < filtered_urls.txt

# Clean up filtered urls file
rm filtered_urls.txt
