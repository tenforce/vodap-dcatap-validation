#!/bin/bash


urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


echo "Content-type: text/html"
echo "Status: $REDIRECT_STATUS Bad Request"
echo ""

cat /scripts/400-badrequest-before.html

echo "<p>Deze uri: "
echo "http://data.vlaanderen.be$REDIRECT_URL"
echo " is foutief." 
echo "</p><br/>"

cat /scripts/nonfound-after.html
 
exit 0
