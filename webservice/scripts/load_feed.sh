#!/bin/bash

URL=$1
#DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DATESTAMP=$2

LOAD="load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>"


#REQUEST="http://localhost:8890/sparql"

curl --data-urlencode "query=$LOAD" $ENV_SPARQL_ENDPOINT_SERVICE_URL
