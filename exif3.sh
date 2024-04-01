#!/bin/bash

# Check if url.txt exists
if [ ! -f "url.txt" ]; then
    echo "Error: File url.txt not found."
    exit 1
fi

# Loop through each URL in url.txt
while IFS= read -r url; do
    # Download the file
    wget -q "$url" -O temp_file
    
    # Run exiftool on the downloaded file
    exif_data=$(exiftool temp_file)
    
    # Check if sensitive metadata is present
    if grep -q -E "Latitude|Longitude|Comments|GPSLocation|Passwords" <<< "$exif_data"; then
        echo "Sensitive metadata found in: $url" | notify -pc provider-config.yaml
    else
        echo "No sensitive metadata found in: $url"
    fi
    
    # Clean up temporary file
    rm temp_file
done < "url.txt"
