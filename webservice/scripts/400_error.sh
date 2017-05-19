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
echo " voldoet niet aan de VO URI strategie."
echo "</p><br/>"

echo "<p>Oorzaak is "
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
echo "</p>"

cat /scripts/nonfound-after.html
 
exit 0
