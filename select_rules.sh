#!/bin/bash

FILE=$2
RULESOURCE=$1

grep "; M ; rule" $FILE > S1
sed -e "s/.*\(rule.*rq\).*/\1/" S1 > S2

while read p; do
  echo $p
  cp $RULESOURCE/rules/$p rules
done < S2

# Clean up
rm -f S1 S2


