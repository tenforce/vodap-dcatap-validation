#!/bin/bash
####################################################################################
# datasets.sh
#   Script to recover a paged DCAT catalog, load it into the endpoint and recover the 
#   list of publishers.

source ./log.sh
source ./cgi.sh

cgi_getvars BOTH ALL

# Variables which can be overriden (via a form or the interface)
dcat_url=${dcat_url:-ENV_CATALOG_LOCATION}
pages_start=${pages_start:-1}
pages_end=${pages_end:-5}
cleancache=no

# Endpoint to load into
#SPARQL_ENDPOINT_SERVICE_URL="http://vodapweb-virtuoso:8890/sparql"
SPARQL_ENDPOINT_SERVICE_URL="ENV_SPARQL_ENDPOINT_SERVICE_URL"

DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DEFAULT_GRAPH=http://data.vlaanderen.be/id/dataset/$DATESTAMP
export PROCESSDIR=/www/results/$DATESTAMP

####################################################################################
# Page contents with one link per publisher.
rm -f $PROCESSDIR/tmp.list
output_line() { # x Link UUID Name
    pointer=$(urlencode "http://ENV_VALIDATOR_LOCATION"$4)
    label=$(echo $2 | tr -d '"')
    nm=$(echo $3 | tr -d '"')
    echo "<li><a href=\"http://ENV_VALIDATOR_LOCATION/dataset?dcat_url=$pointer\">"$label" - ("$nm")</a></li>" >>  $PROCESSDIR/tmp.list
}

###################################################################################
# Recovering the catalog.n3 file is an expensive operation which can sometimes
# timeout. The following will attempt to first recover the document and then cache
# the file, so that in the even of a timeout (in subsequent operations), the
# file does not need to be downloaded again. The cache is based on todays' name
# and an md45 hash key of the page reference URL. The instruction passed to
# virtuoso is to download the cached file (from the md5has key file) rather than
# got to the web.
# 
mkdir -p $PROCESSDIR
log "Loading of the catalog $dcat_url started (from $pages_start to $pages_end) into $PROCESSDIR"

# Setup a cache area to to used (cleanring older files out if already existing)
CACHENAME=$(date '+%A')
CACHEDIR=/www/results/cache/$CACHENAME
if [ "${cleancache}" == "yes" ] ; then
    rm -rf ${CACHEDIR}
elif [ -d "${CACHEDIR}" ] ; then
    # clean the cache of older files (speed?)
    find ${CACHEDIR} -mtime +1 -exec rm {} \;
else
    true
fi

# make sure that the cachedir exists
mkdir -p $CACHEDIR     

# Recover the file requested, but put contents in a cache

log "recovering ${pages_start} to ${pages_end} pages"
for (( i=${pages_start}; i<=${pages_end}; i++ )); do
    reference=$(echo "${dcat_url}?validation_mode=true&page=${i}")
    log "printf '%s' \"${reference}\" \| md5sum \| cut -d ' ' -f 1"
    cachekey=$(printf '%s' "${reference}" | md5sum | cut -d ' ' -f 1)
    newref="http://ENV_VALIDATOR_LOCATION/results/cache/${CACHENAME}/${cachekey}.n3"
    log "recovering page ${i} ${cachekey}"    
    if [ ! -f "$CACHEDIR/${cachekey}.n3" ] ; then
	# recover the reference and put in cache file.
	log "caching (--compressed) $reference in $newref"
	curl --compressed $reference > ${CACHEDIR}/${cachekey}.n3
    fi
    # Add the cached file to the list of files to be loaded by virtuoso
    DCATURLS+=" ${newref} "
done

####################################################################################
log "call: ./load_feeds.sh $DATESTAMP $DCATURLS"

./load_feeds.sh $DATESTAMP $DCATURLS

####################################################################################
log "Get publishers List $SPARQL_ENDPOINT_SERVICE_URL $pwd"

curl --data-urlencode query="`cat query/publishers.rq`"  \
     --data format="text/csv" \
     --data-urlencode default-graph-uri="$DEFAULT_GRAPH" \
     -o $PROCESSDIR/publishers.csv $SPARQL_ENDPOINT_SERVICE_URL \
     >> /logs/webservice.log 2>&1

####################################################################################
log "Contructing Queries and Getting publishers"
cat $PROCESSDIR/publishers.csv >> /logs/webservice.log

# for each publisher, the query is created and executed, all results are
# saved for debugging purposes.
while IFS=, read PubID Name PubUUID PubOld ; do
    log "Publisher $PubID $Name query start"
    RPubID=$(echo ${PubID} | tr -d '"')
    fn=$(echo ${RPubID} | md5sum | cut -d ' ' -f 1) ;
    sed -e "s@PUBID@$RPubID@g" query/dataset.template > $PROCESSDIR/name$fn.rq ;
    curl --data-urlencode query="`cat $PROCESSDIR/name$fn.rq`" \
	 --data format="RDF/XML" \
	 --data-urlencode default-graph-uri="$DEFAULT_GRAPH" \
	 -o $PROCESSDIR/name$fn.nt $SPARQL_ENDPOINT_SERVICE_URL >> /logs/webservice.log 2>&1
    output_line "${PubId}" "$Name" "$PubUUID" "/results/$DATESTAMP/name$fn.nt"
    log "Publisher $PubID query end"
done < $PROCESSDIR/publishers.csv

####################################################################################
log "Publisher data should be recovered"

cat /scripts/datasets-list-before.html > $PROCESSDIR/datasets.html
echo '<h3>Pages '$pages_start'..'$pages_end'</h3><ul>' >> $PROCESSDIR/datasets.html
tail -n +2 $PROCESSDIR/tmp.list >> $PROCESSDIR/datasets.html
echo '</ul>' >> $PROCESSDIR/datasets.html
cat /scripts/datasets-list-after.html >> $PROCESSDIR/datasets.html

#echo "Content-type: text/html"
#echo ""
#echo '<html>'
#echo '<head>'
#echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
#echo '<title>http://opendata.vlaanderen.be/catalog.rdf</title>'
#echo '</head>'
#echo '<body>'
#echo '<h1>Publishers found in http://opendata.vlaanderen.be/catalog.rdf</h1>'
#echo '<h3>Pages '$pages_start'..'$pages_end'</h3><ul>'
#tail -n +2 $PROCESSDIR/tmp.list 
#echo '</ul></body>'
#echo '</html>'

echo "Content-type: text/html"
echo "Status: 302 Redirect"
echo "Location: http://ENV_VALIDATOR_LOCATION/results/$DATESTAMP/datasets.html"
echo ""
echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<title>Redirect</title>'
echo '</head>'
echo '<body/>'
echo '</html>'
exit 0
####################################################################################
####################################################################################
