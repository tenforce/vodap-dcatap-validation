#!/bin/bash
#RESULTSFILE=genreports.csv
RESULTSFILE=$1
#OUTPUTFILE=report.org
OUTPUTFILE=$2
MAXLINES=30

genstatistics() {
  ERRORS=`egrep ",error," ${RESULTSFILE} | wc -l`
  WARNINGS=`egrep ",warning," ${RESULTSFILE} | wc -l`
  echo "|" errors "|" $ERRORS "|"
  echo "|" warnings "|" $WARNINGS "|"
}

  includestats() {
  # change the out separator for org-mode
  awk -F, '{print "|" $1 "|" $2 "|" ;}' query/basic.csv
}

genruleresults() {
  for i in {0..256} 
  do
    ITEMS=`egrep ",$i," ${RESULTSFILE} | awk -F, '{print "|" $1 "|" $3 "|" $4 "|" $5 "|" $6 "|"; }'`
    if [ ! -z "$ITEMS" ] ; then
       echo "** Rule $i"
       echo "$ITEMS" | head -${MAXLINES}
    fi
  done
}

genreport() {
  echo "#+TITLE: DCAT Validation Report (catalog.rdf file)"
  echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"http://www.pirilampo.org/styles/readtheorg/css/htmlize.css\"/>"
  echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"http://www.pirilampo.org/styles/readtheorg/css/readtheorg.css\"/>"
  echo "#+HTML_HEAD: <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>"
  echo "#+HTML_HEAD: <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>"
  echo "#+HTML_HEAD: <script type=\"text/javascript\" src=\"http://www.pirilampo.org/styles/lib/js/jquery.stickytableheaders.js\"></script>"
  echo "#+HTML_HEAD: <script type=\"text/javascript\" src=\"http://www.pirilampo.org/styles/readtheorg/js/readtheorg.js\"></script>"
  # echo "#+SETUPFILE: ~/SpiderOak/Org/org-html-themes/setup/theme-readtheorg.setup"
  echo "* Introduction"
  includestats
  echo "* Statistics"
  genstatistics
  echo "* Individual Rule Results"
  genruleresults
}

genreport > $OUTPUTFILE
