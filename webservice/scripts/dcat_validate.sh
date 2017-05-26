#!/bin/bash
# run the DCAT-AP validation rules

source ./log.sh
# PROCESSDIR is set by the caller script
log "dcat_validate: $PROCESSDIR"

# if not set, this is the default
SPARQL_ENDPOINT_SERVICE_URL="ENV_SPARQL_ENDPOINT_SERVICE_URL"
# default should be checked for empty value
DEFAULT_GRAPH=$1

# probably not needed since it will be executed on a new directory each time
rm -f $PROCESSDIR/vodapreport.csv
rm -f $PROCESSDIR/vodapreport.org

# run the basic rules
log "$PROCESSDIR: run dcat validation rules"
for i in /rules/basic/*.rq ; do 
     # overwrite currently all results in basic.csv
     curl -s --data-urlencode "query=`cat $i`"  --data-urlencode "format=text/csv" --data-urlencode "default-graph-uri=$DEFAULT_GRAPH" -o $PROCESSDIR/basic.csv $SPARQL_ENDPOINT_SERVICE_URL 
done 

# run the validation rules
log "$PROCESSDIR: run dcat validation rules"
for i in /rules/dcat/*.rq ; do 
     curl -s --data-urlencode "query=`cat $i`"  --data-urlencode "format=text/csv" --data-urlencode "default-graph-uri=$DEFAULT_GRAPH" $SPARQL_ENDPOINT_SERVICE_URL 
done | egrep -v Class_Name > $PROCESSDIR/vodapreport.csv

# generate the org fle
log "$PROCESSDIR: generate the org file"
./genreport.sh $PROCESSDIR/vodapreport.csv $PROCESSDIR/vodapreport.org $PROCESSDIR/basic.csv 

# style the output
./org-export $PROCESSDIR/vodapreport.org > $PROCESSDIR/vodapreport.html 2>> /logs/validate.log

