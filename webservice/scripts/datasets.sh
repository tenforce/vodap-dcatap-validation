#!/bin/bash

source ./log.sh
source ./cgi.sh

cgi_getvars BOTH ALL

DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
DEFAULT_GRAPH=http://data.vlaanderen.be/id/dataset/$DATESTAMP
SPARQL_ENDPOINT_SERVICE_URL="http://vodapweb-virtuoso:8890/sparql"
export PROCESSDIR=/www/results/$DATESTAMP
dcat_url=http://opendata.vlaanderen.be/catalog.rdf
pages_start=${pages_start:-1}
pages_end=${pages_end:-15}

rm -f $PROCESSDIR/tmp.list
output_line() {
    pointer=$(urlencode "http://webservice"$3)
    label=$(echo $2 | tr -d '"')
    echo "<li><a href=\"/dataset?dcat_url=$pointer\">"$label"</a></li>" >>  $PROCESSDIR/tmp.list
}

mkdir -p $PROCESSDIR
log "Loading of the catalog started"
DCATURLS=""
for (( i=${pages_start}; i<=${pages_end}; i++ )); do
    DCATURLS+=" $dcat_url?page=$i "
done
./load_feeds.sh $DATESTAMP $DCATURLS

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
    output_line "${PubId}" "$Name" "/results/$DATESTAMP/name$fn.nt"
    log "Publisher $PubID query end"    
done < $PROCESSDIR/publishers.csv

echo "Content-type: text/html"
echo ""
echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<title>http://opendata.vlaanderen.be/catalog.rdf</title>'
echo '</head>'
echo '<body>'
echo '<h1>Publishers found in http://opendata.vlaanderen.be/catalog.rdf</h1>'
echo '<h3>Pages '$pages_start'..'$pages_end'</h3><ul>'
tail -n +2 $PROCESSDIR/tmp.list 
echo '</ul></body>'
echo '</html>'
exit 0
