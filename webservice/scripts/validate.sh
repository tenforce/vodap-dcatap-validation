#!/bin/bash

source ./log.sh

#This code for getting code from post data is from http://oinkzwurgl.org/bash_cgi and
#was written by Phillippe Kehi &lt;phkehi@gmx.net&gt; and flipflip industries

# (internal) routine to store POST data
function cgi_get_POST_vars()
{
    # check content type
    # FIXME: not sure if we could handle uploads with this..
    [ "${CONTENT_TYPE}" != "application/x-www-form-urlencoded" ] && \
	echo "Warning: you should probably use MIME type "\
	     "application/x-www-form-urlencoded!" 1>&2
    # save POST variables (only first time this is called)
    [ -z "$QUERY_STRING_POST" \
      -a "$REQUEST_METHOD" = "POST" -a ! -z "$CONTENT_LENGTH" ] && \
	read -n $CONTENT_LENGTH QUERY_STRING_POST
    return
}

# (internal) routine to decode urlencoded strings
function cgi_decodevar()
{
    [ $# -ne 1 ] && return
    local v t h
    # replace all + with whitespace and append %%
    t="${1//+/ }%%"
    while [ ${#t} -gt 0 -a "${t}" != "%" ]; do
	v="${v}${t%%\%*}" # digest up to the first %
	t="${t#*%}"       # remove digested part
	# decode if there is anything to decode and if not at end of string
	if [ ${#t} -gt 0 -a "${t}" != "%" ]; then
	    h=${t:0:2} # save first two chars
	    t="${t:2}" # remove these
	    v="${v}"`echo -e \\\\x${h}` # convert hex to special char
	fi
    done
    # return decoded string
    echo "${v}"
    return
}

# routine to get variables from http requests
# usage: cgi_getvars method varname1 [.. varnameN]
# method is either GET or POST or BOTH
# the magic varible name ALL gets everything
function cgi_getvars()
{
    [ $# -lt 2 ] && return
    local q p k v s vv
    # get query
    case $1 in
	GET)
	    [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
	    ;;
	POST)
	    cgi_get_POST_vars
	    [ ! -z "${QUERY_STRING_POST}" ] && q="${QUERY_STRING_POST}&"
	    ;;
	BOTH)
	    [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
	    cgi_get_POST_vars
	    [ ! -z "${QUERY_STRING_POST}" ] && q="${q}${QUERY_STRING_POST}&"
	    ;;
    esac
    shift
    s=" $* "
    # parse the query data
    while [ ! -z "$q" ]; do
	p="${q%%&*}"  # get first part of query string
	k="${p%%=*}"  # get the key (variable name) from it
	v="${p#*=}"   # get the value from it
	q="${q#$p&*}" # strip first part from query string
	# decode and evaluate var if requested
	if [ "$1" = "ALL" -o "${s/ $k /}" != "$s" ] ; then 
	    vv=`cgi_decodevar \"$v\"`
	    eval "$k=$vv"
	fi
    done
    return
}

# register all GET and POST variables

urldecode() {
    # urldecode <string>
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

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
echo "Location: http://localhost/results/$DATESTAMP"
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
