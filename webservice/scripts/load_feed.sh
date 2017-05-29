#!/bin/bash
# PROCESSDIR is set by caller script

source ./log.sh

URL=$1
#DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DATESTAMP=$2

log "load_feed: $PROCESSDIR"
SPARQL_ENDPOINT_SERVICE_URL="ENV_SPARQL_ENDPOINT_SERVICE_URL"

LOAD="load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>"

curl -s -o $PROCESSDIR/load_feed.log --data-urlencode "query=$LOAD" $SPARQL_ENDPOINT_SERVICE_URL

STATUS=$?
log "load_feed: STATUS $STATUS"

exit $STATUS
