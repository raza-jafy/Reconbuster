#!/bin/bash

rm -f urls.txt
rm -f live-urls.txt
rm -f subdomains.txt
rm -f unique-urls.txt
rm -f reuslts.txt
#excluded_extentions="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"
# ANSI color codes
green='\033[0;32m'
reset='\033[0m'


echo
echo
echo -e "${green}Running Paramspider${reset}"
subfinder -dL domains.txt -all -silent -o subdomains.txt

echo
echo
echo -e "${green}Running Katana${reset}"
cat subdomains.txt | katana -jc -f qurl -d 5 -c 50 -kf robotstxt,sitemapxml -silent -o urls.txt

echo
echo
echo -e "${green}Sorting Urls${reset}"
uro -i urls.txt -o unique-urls.txt

echo
echo
echo -e "${green}Running Httpx${reset}"
httpx -l unique-urls.txt -silent -mc 200,301,302 -o live-urls.txt

echo
echo
echo -e "${green}Running Nuclei${reset}"
nuclei -l live-urls.txt -dast -iserver uxxbakcpqehrnrfowwuxguhai0imvotcr.oast.fun -o results.txt | notify -silent -pc provider-config.yaml

echo
echo
echo -e "${green}Scan Ended${reset}" | notify -silent -pc provider-config.yaml


