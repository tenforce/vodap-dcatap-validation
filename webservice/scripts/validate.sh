#!/bin/bash
####################################################################################
# title:       validate.sh
# description: 
#
source ./cgi.sh
source ./log.sh

cgi_getvars BOTH ALL

####################################################################################
# add a default for testing purposes.
if [ "$dcat_url" = "" ] ; then
    dcat_url="http://data.kortrijk.be/api/dcat"
fi

log "used ruleset = ${regels}"

DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
export PROCESSDIR=/www/results/$DATESTAMP

mkdir -p $PROCESSDIR
# Empty directory if it already exists.
rm -f $PROCESSDIR/*

####################################################################################
# Pass the URL and location of where to put the results to the validation script.
# Response from the validate is used to determine what is to be sent to the user
# (possibilities include load error, parsing error or the final report itself).
#
log "BEFORE: ./rdf_validate_url.sh $dcat_url $DATESTAMP"
./rdf_validate_url.sh $dcat_url $DATESTAMP
ec=$?
log "AFTER: ${ec}"
case "${ec}" in
    0) log "BEFORE: load_feed.sh $dcat_url $DATESTAMP"
       # only continue if previous is success
       LOCALFEED="https://ENV_VALIDATOR_LOCATION/results/$DATESTAMP/feed.$DATESTAMP"
       ./load_feeds.sh $DATESTAMP $LOCALFEED
       #./load_feeds.sh $DATESTAMP $dcat_url
       LOADSTATUS=$?
       if [ "${LOADSTATUS}" == "0" ] ; then
	   log "LOADSTATUS = ${LOADSTATUS}"		
	   case "${regels}" in
		1) ./dcatapvl_mandatory_validate.sh http://data.vlaanderen.be/id/dataset/$DATESTAMP $dcat_url $DATESTAMP
		;;
		2) ./dcatap_recommended_validate.sh http://data.vlaanderen.be/id/dataset/$DATESTAMP $dcat_url $DATESTAMP
		;;
		3) ./dcatap_full_validate.sh http://data.vlaanderen.be/id/dataset/$DATESTAMP $dcat_url $DATESTAMP
		;;
		4) ./dereference.sh $DATESTAMP
		   ./dcatapvl_mandatory_validate.sh http://data.vlaanderen.be/id/dataset/$DATESTAMP $dcat_url $DATESTAMP
		;;
		*) ./dcatapvl_mandatory_validate.sh http://data.vlaanderen.be/id/dataset/$DATESTAMP $dcat_url $DATESTAMP
		;;
           esac
	   log "Set Pointer to $PROCESSDIR/vodapreport.html"
	   ln -s $PROCESSDIR/vodapreport.html $PROCESSDIR/index.html
	   # all the links to the original report are fond in the generated document
       else
	   log "REDIRECT to load_feed,log - load problem (in /ENV_VALIDATOR_LOCATION_PATH/results/$DATESTAMP)"	
	   ln -s $PROCESSDIR/load_feed.log $PROCESSDIR/index.html
       fi
       REDIRECT="http://ENV_VALIDATOR_LOCATION/results/$DATESTAMP"
       ;;

    1) # File can be downloaded, but there is a parsing error
       log "1 status, REDIRECT to load_feed.log - load problem (in /ENV_VALIDATOR_LOCATION_PATH/results/$DATESTAMP)"
       ln -s $PROCESSDIR/feed.$DATESTAMP.report $PROCESSDIR/index.html
       REDIRECT="http://ENV_VALIDATOR_LOCATION/bin/148_error.sh?dcat_url=$dcat_url&details=/ENV_VALIDATOR_LOCATION_PATH/results/$DATESTAMP/feed.$DATESTAMP.report"       
       ;;

    2) # File cannot be downloaded, so redirect to the 404 message
       ln -s $PROCESSDIR/feed.$DATESTAMP.report $PROCESSDIR/index.html
       log "404 code, /ENV_VALIDATOR_LOCATION_PATH/bin/404_error.sh?dcat_url=$dcat_url"
       REDIRECT="http://ENV_VALIDATOR_LOCATION/bin/404_error.sh?dcat_url=$dcat_url"
       ;;
  
  148) # File can be downloaded, but there is a parsing error
       # ln -s $PROCESSDIR/feed.$DATESTAMP.report $PROCESSDIR/index.html
       log "148 code, REDIRECT to $PROCESSDIR/feed.$DATESTAMP.report - load problem (in /ENV_VALIDATOR_LOCATION_PATH/results/$DATESTAMP)"
       REDIRECT="http://ENV_VALIDATOR_LOCATION/bin/148_error.sh?dcat_url=$dcat_url&details=/ENV_VALIDATOR_LOCATION_PATH/results/$DATESTAMP/feed.$DATESTAMP.download"       
       ;;

    *) # no idea what the response code is.
       log "Unknown error - ec = ${ec}"
       REDIRECT="http://ENV_VALIDATOR_LOCATION/bin/404_error.sh?dcat_url=$dcat_url"
       ;;
esac

####################################################################################
echo "Content-type: text/html"
echo "Status: 302 Redirect"
echo "Location: ${REDIRECT}"
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
# 1
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
####################################################################################
####################################################################################
