#!/bin/bash
# PROCESSDIR is set by caller script

source ./log.sh

#SPARQL_ENDPOINT_SERVICE_URL="http://vodapweb-virtuoso:8891/sparql"
#DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DATESTAMP=$1
shift;

log "load_feed parts"
LOAD=""
for i in "$@"
do
 URL=$i
 log "load_feed: load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>"
 log "load_feed: LOAD command is $LOAD"
 LOAD+="load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP> "
done 

log "load_feed: " curl -s -o "$PROCESSDIR/load_feed.log" --data-urlencode "query=\"$LOAD\"" ENV_SPARQL_ENDPOINT_SERVICE_URL
curl -s -o $PROCESSDIR/load_feed.log --data-urlencode "query=$LOAD" ENV_SPARQL_ENDPOINT_SERVICE_URL

STATUS=$?
log "load_feed: STATUS $STATUS"
exit $STATUS
