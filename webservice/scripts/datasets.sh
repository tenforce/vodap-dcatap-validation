#!/bin/bash

source ./log.sh

DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DEFAULT_GRAPH=http://data.vlaanderen.be/id/dataset/$DATESTAMP
SPARQL_ENDPOINT_SERVICE_URL="http://vodapweb-virtuoso:8890/sparql"
export PROCESSDIR=/www/results/$DATESTAMP
dcat_url=http://opendata.vlaanderen.be/catalog.rdf

urlencode() {
    # urlencode <string> taken from https://gist.github.com/cdown/1163649
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    
    LC_COLLATE=$old_lc_collate
}


rm $PROCESSDIR/tmp.list
output_line() {
    pointer=$(urlencode "http://webservice"$3)
    echo "<li><a href=\"/dataset?dcat_url=$pointer\">"$2"</a></li>" >>  $PROCESSDIR/tmp.list
}

mkdir -p $PROCESSDIR

log "Dataset construction started"
./load_feed.sh $dcat_url $DATESTAMP

log "Get publishers List $SPARQL_ENDPOINT_SERVICE_URL $pwd"

curl --data-urlencode query="`cat query/publishers.rq`"  --data format="text/csv" --data-urlencode default-graph-uri="$DEFAULT_GRAPH" -o $PROCESSDIR/publishers.csv $SPARQL_ENDPOINT_SERVICE_URL >> /logs/webservice.log 2>&1

cat $PROCESSDIR/publishers.csv >> /logs/webservice.log

log "Contructing Queries and Getting publishers"

while IFS=, read PubID Name;
do
    log "Publisher $PubID $Name query start"
    RPubID=$(echo ${PubID} | tr -d '"')
    fn=$(echo ${RPubID} | md5sum | cut -d ' ' -f 1) ;
    sed -e "s@PUBID@$RPubID@g" query/dataset.template > $PROCESSDIR/name$fn.rq ;
    curl --data-urlencode query="`cat $PROCESSDIR/name$fn.rq`" --data format="RDF/XML" --data-urlencode default-graph-uri="$DEFAULT_GRAPH" -o $PROCESSDIR/name$fn.nt $SPARQL_ENDPOINT_SERVICE_URL >> /logs/webservice.log 2>&1
    output_line "${PubId}" "$Name" "$PROCESSDIR/name$fn.nt"
    log "Publisher $PubID query end"    
done < $PROCESSDIR/publishers.csv

echo "Content-type: text/html"
echo ""
echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<title>Error</title>'
echo '</head>'
echo '<body>'
echo '<h1>Dataset Links</h1><ul>'
cat $PROCESSDIR/tmp.list
echo '</ul></body>'
echo '</html>'
exit 0
