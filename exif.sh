#!/bin/bash
#Confidential-Exiftool

# Download wildcards.txt and save it as target-wildcards.txt
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/domains.txt" | anew target-wildcards.txt

# Run gau to collect subdomains and save them to urls.txt
cat target-wildcards.txt | gau --subs --threads 16 | anew gau-urls.txt | uro | anew unique-urls.txt

cat unique-urls.txt | grep -E '\.(docx|rtf|jpeg|png|svg|img|tsv|csv|odt)$' | httpx -silent -mc 200 | anew urls.txt 
rm unique-urls.txt

# Define arrays of file extensions to search for
document_extensions=("odt" "csv" "tsv" "docx" "rtf")
image_extensions=("jpeg" "png" "svg" "jpg" "img")

# Function to process documents
process_document() {
    local file="$1"
    
    # Convert the document into text using pandoc
    pandoc "$file" -o temp.txt
    
    # Search for specific text in the document
    if grep -q "internal use only|confidential" temp.txt; then
        echo "Found sensitive text in: $url && notify -silent -id Confidential-Exif1, Confidential-Exif2 | tee document-finding.txt"
    fi
    
    # Run exiftool on the document
    exiftool "$file" | grep -E "Latitude|Longitude|GPSLocation|comments|passwords|password|URL" && echo "\nFound metadata in: $url && notify -silent -id Confidential-Exif1, Confidential-Exif2| tee exif-finding.txt"
    
    # Clean up temporary files
    rm temp.txt
}

# Process documents with specified extensions
for ext in "${document_extensions[@]}"; do
    # Search for URLs with the current extension
    grep -E "\.${ext}$" urls.txt | while read -r url; do
        # Download the file
        curl -s "$url" -o temp.$ext
        process_document "temp.$ext"
        rm "temp.$ext"
    done
done

# Process images with specified extensions
for ext in "${image_extensions[@]}"; do
    # Search for URLs with the current extension
    grep -E "\.${ext}$" urls.txt | while read -r url; do
        # Download the file
        curl -s "$url" -o temp.$ext
        
        # Run exiftool on the image
        exiftool "temp.$ext" | grep -E "Latitude|GPSLocation|Longitude|comments|passwords|password|URL" && echo "\nFound metadata in: $url" && echo "\nMetadata: $metadata && notify -silent -id Confidential-Exif1, Confidential-Exif2  | tee exif-finding.txt"
        
        # Clean up temporary files
        rm "temp.$ext"
    done
done
