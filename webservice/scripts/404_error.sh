#!/bin/bash


urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


echo "Content-type: text/html"
echo "Status: $REDIRECT_STATUS NOT FOUND"
echo ""

cat /scripts/404-nonfound-before.html

echo "<p>Deze uri: "
echo "http://data.vlaanderen.be$REDIRECT_URL"
echo " is niet gevonden. " 
echo "</p><br/>"


cat /scripts/nonfound-after.html
 
exit 0
