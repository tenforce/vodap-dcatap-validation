#!/bin/bash
# run the DCAT-AP validation rules

# if not set, this is the default
#ENV_SPARQL_ENDPOINT_SERVICE=http://localhost:8890/sparql
# default should be checked for empty value
DEFAULT_GRAPH=$1

rm vodapreport.csv
rm vodapreport.org

# run the validation rules
echo "run validation rules"
for i in rules/*.rq ; do 
     curl -s --data-urlencode "query=`cat $i`"  --data-urlencode "format=text/csv" --data-urlencode "default-graph-uri=$DEFAULT_GRAPH" $ENV_SPARQL_ENDPOINT_SERVICE 
done | egrep -v Class_Name > vodapreport.csv

# generate the org fle
echo "generate the org file"
./genreport.sh vodapreport.csv vodapreport.org > vodapreport.org

# style the output
#	${SUDO} ./docker-org-export/docker-org-export vodapreport.org 

