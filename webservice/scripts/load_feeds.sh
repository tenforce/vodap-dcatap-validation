#!/bin/bash
# PROCESSDIR is set by caller script

source ./log.sh

SPARQL_ENDPOINT_SERVICE_URL="http://vodapweb-virtuoso:8890/sparql"
#DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DATESTAMP=$1
shift;

log "load_feed parts"
LOAD=""
part=0
for i in "$@"
do
 URL=$i
 log "load_feed: load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>"
 log "load_feed: LOAD command is $LOAD"
 # LOAD="load <http://webservice/results/$DATESTAMP/part-${part}.rdf> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>" 
 LOAD+="load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP> "
 # curl -s -o $PROCESSDIR/part-${part}.rdf $URL 
done 
log curl -s -o "$PROCESSDIR/load_feed.log" --data-urlencode "query=$LOAD" $SPARQL_ENDPOINT_SERVICE_URL
curl -s -o $PROCESSDIR/load_feed.log --data-urlencode "query=$LOAD" $SPARQL_ENDPOINT_SERVICE_URL

STATUS=$?
log "load_feed: STATUS $STATUS"
exit $STATUS
