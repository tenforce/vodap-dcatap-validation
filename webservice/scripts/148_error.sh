#!/bin/bash

source ./log.sh
source ./cgi.sh

urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

cgi_getvars BOTH ALL

# add a default for testing
if [ "$dcat_url" = "" ] ; then
    referenceurl="http://data.vlaanderen.be$REDIRECT_URL"
else
    referenceurl=$dcat_url
fi

echo "Content-type: text/html"
echo "Status: $REDIRECT_STATUS NOT FOUND"
echo ""

cat /scripts/404-nonfound-before.html

echo "<p>Parsing issuer for uri: "
echo "${referenceurl}" "see <a href=\""$details"\">Details</a>"

echo "</p><br/>"


cat /scripts/nonfound-after.html
 
exit 0
