#!/bin/bash

grep "M rule" $1 > S1
sed -e "s/.*\(rule.*\):#.*/\1/" S1 > selected_rules.txt

while read p; do
  echo $p
  cp dcat-ap_validator/rules/$p vodap-rules
done < selected_rules.txt
