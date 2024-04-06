#!/bin/bash

rm -f urls.txt
rm -f live-urls.txt
excluded_extentions="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"
# ANSI color codes
green='\033[0;32m'
reset='\033[0m'


echo -e "${green}Running Paramspider${reset}"
/root/ParamSpider/paramspider.py -l nowaf.txt -s --exclude "$excluded_extentions" --level high --quiet -o urls.txt

echo -e "${green}Running Httpx${reset}"
cat urls.txt | httpx -silent -mc 200,301,302 | uro | anew live-urls.txt

echo -e "${green}Running Nuclei${reset}"
nuclei -l live-urls.txt -t "/root/fuzzing-templates" -iserver uxxbakcpqehrnrfowwuxguhai0imvotcr.oast.fun -fuzz -debug-req -rl 05 -o results.txt | notiffy
