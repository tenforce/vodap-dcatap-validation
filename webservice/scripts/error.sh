#!/bin/bash


urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


echo "Content-type: text/html"
echo "Status: $REDIRECT_STATUS Condition Intercepted"
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


echo "Deze uri: "
echo "http://data.vlaanderen.be$REDIRECT_URL"
echo " voldoet niet aan de Vlaamse Overheid URI strategie."
echo "\n"

echo "Oorzaak is "
case $REDIRECT_errorUriScheme in
   0) echo "onbekende categorie"
      ;;
   1) echo "geaccepteerde categorie, maar lege identificatie"
      ;;
   2) 	echo "Er is geen (ondersteunde) Accept-header gevonden."
      	echo "Een Accept header is <b>verplicht</b> en 1 van deze waarden:"
	echo "<ul>"
	echo "<li>text/html</li>"
	echo "<li>application/rdf+xml</li>"
	echo "<li>text/turtle</li>"
	echo "</ul>"
        echo "Er is niet gekozen voor een HTTP 300 Multiple Choice respons, omdat er geen eenvormige respons gedefinieerd is".
        echo "Voor meer informatie zie <a href="https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation">documentatie over Content Negotatie van de Mozilla foundation</a>."
      ;;
   *) echo "onbekende oorzaak"
      ;;
esac

#echo "$HTTP_REFERER"
#echo "--"
#echo "$REDIRECT_URL"
#echo "--"
#echo "$REQUEST_URI"
#echo "--"
#echo "$REDIRECT_errorUriScheme" 
#
#

#echo "------------------------\n"
#env

echo '</body>'
echo '</html>'
 
exit 0
