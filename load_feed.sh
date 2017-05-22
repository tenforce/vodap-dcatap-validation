#!/bin/bash

URL=$1
DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
LOAD="load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>"


REQUEST="http://localhost:8890/sparql"

echo $LOAD
echo $REQUEST

curl --data-urlencode "query=$LOAD" $REQUEST
