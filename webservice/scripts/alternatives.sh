#!/bin/bash


urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


echo "Content-type: text/html"
echo "Status: 300 Multiple Choices"
#echo "Location: http://data.vlaanderen.be$REQUEST_URI"
#echo "Location: http://data.vlaanderen.be$REQUEST_URI"
echo ""
echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<title>Alternatives</title>'
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


echo "Deze uri: "
echo "http://data.vlaanderen.be$REQUEST_URI"
echo " heeft verschillende alternatieven."

echo "De volgende accept headers worden ondersteund:"
echo "<ul>"
echo "<li>text/html</li>"
echo "<li>application/rdf+xml</li>"
echo "<li>text/turtle</li>"
echo "</ul>"

#echo "$HTTP_REFERER"
#echo "--"
#echo "$REDIRECT_URL"
#echo "--"
#echo "$REQUEST_URI"
#echo "--"
#echo "$REDIRECT_errorUriScheme" 
#
#


echo '</body>'
echo '</html>'
 
exit 0
