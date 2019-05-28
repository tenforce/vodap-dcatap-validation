#!/bin/bash
####################################################################################
# PROCESSDIR is set by caller script

source ./log.sh


# 
# dereference some URIs in the catalog to obtain their descriptions
#
# assumption is that the catalog is in ntriples

DATESTAMP=$1
CATALOG=/www/results/$DATESTAMP/feed.$DATESTAMP.report

LICENSE=`cat ${CATALOG} | grep terms  |grep license |sed "s/^.*<//" |sed "s/>.*$//" | sort -u `

echo ${LICENSE}
####################################################################################

if [ -n ${LICENSE} ] ; then 
LOAD=""
for i in ${LICENSE} 
do
 URL=$i
 log "dereference: load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP>"
 log "dereference: LOAD command is $LOAD"
 LOAD+="load <$URL> into <http://data.vlaanderen.be/id/dataset/$DATESTAMP> "
done

log "dereference: " curl -o "$PROCESSDIR/dereference.log" --data-urlencode "query=\"$LOAD\"" ENV_SPARQL_ENDPOINT_SERVICE_URL
curl -o $PROCESSDIR/dereference.log --data-urlencode "query=$LOAD" ENV_SPARQL_ENDPOINT_SERVICE_URL

STATUS=$?
else
STATUS=0
fi

log_file $PROCESSDIR/dereference.log
log "dereference: STATUS $STATUS"
exit $STATUS

####################################################################################
