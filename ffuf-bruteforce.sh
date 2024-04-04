#!/bin/bash

ffuf -w onelistforallaa -u https://dreambox.my.salesforce.com/FUZZ -mc 200 -ac -fl 47 | notify -silent -pc provider-config.yaml
