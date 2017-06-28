#!/bin/bash

source ./log.sh
source ./cgi.sh

cgi_getvars BOTH ALL

# add a default for testing
if [ "$dcat_url" = "" ] ; then
    dcat_url="http://data.kortrijk.be/api/dcat"
fi

DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
export PROCESSDIR=/www/results/$DATESTAMP
mkdir -p $PROCESSDIR

log "BEFORE: ./rdf_validate_url.sh $dcat_url $DATESTAMP"

./rdf_validate_url.sh $dcat_url $DATESTAMP
ec=$?
#if [ ${ec} -eq 0 ] ; then
    log "BEFORE: load_feed.sh $dcat_url $DATESTAMP"
    # only continue if previous is success
    ./load_feeds.sh $DATESTAMP $dcat_url 
    ./dcat_validate.sh http://data.vlaanderen.be/id/dataset/$DATESTAMP $dcat_url $DATESTAMP
    # all the links to the original report are fond in the generated document
    ln -s $PROCESSDIR/vodapreport.html $PROCESSDIR/index.html
#fi

echo "Content-type: text/html"
echo "Status: 302 Redirect"
echo "Location: http://ENV_VALIDATOR_LOCATION/results/$DATESTAMP"
echo ""
echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<title>Error</title>'
echo '</head>'
echo '<body>'

## Save the old internal field separator.
#  OIFS="$IFS"
## Set the field separator to & and parse the QUERY_STRING at the ampersand.
#  IFS="${IFS}&"
#  set $QUERY_STRING
#  Args="$*"
#  IFS="$OIFS"
# 
## Next parse the individual "name=value" tokens.
# 
#  ARGX=""
#  ARGY=""
#  ARGZ=""
# 
#  for i in $Args ;do
# 
##       Set the field separator to =
#	IFS="${OIFS}="
#	set $i
#	IFS="${OIFS}"
# 
#	case $1 in
#		# Don't allow "/" changed to " ". Prevent hacker problems.
#		uri) ErroneousURI="`echo $2 | sed 's|[\]||g' | sed 's|%20| |g'`"
#		       ;;
#		# Filter for "/" not applied here
#		namey) ARGY="`echo $2 | sed 's|%20| |g'`"
#		       ;;
#		namez) ARGZ="${2/\// /}"
#		       ;;
#		*)     echo "<hr>Warning:"\
#			    "<br>Unrecognized variable \'$1\' passed by FORM in QUERY_STRING.<hr>"
#		       ;;
# 
#	esac
#  done
#
#
#LOCAL=$(urldecode $ErroneousURI)
#echo "http://data.vlaanderen.be/$LOCAL"




#echo "$HTTP_REFERER"
#echo "--"
#echo "$REDIRECT_URL"
#echo "--"
#echo "$REQUEST_URI"
#echo "--"
#echo "$REDIRECT_errorUriScheme" 
#
#

echo $PWD
echo "------------------------\n"
env


echo '</body>'
echo '</html>'
 
exit 0
