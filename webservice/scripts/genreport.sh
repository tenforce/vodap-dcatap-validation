#!/bin/bash
#RESULTSFILE=genreports.csv
RESULTSFILE=$1
#OUTPUTFILE=report.org
OUTPUTFILE=$2
BASICRESULT=$3
ORIGURL=$4
DATESTAMP=$5
MAXLINES=30

URLDATESTAMP=$(echo $DATESTAMP | sed -e 's^:^%3A^g')
genstatistics() {
  ERRORS=`egrep ",\"error\"," ${RESULTSFILE} | wc -l`
  WARNINGS=`egrep ",\"warning\"," ${RESULTSFILE} | wc -l`
  echo "|" errors "|" $ERRORS "|"
  echo "|" warnings "|" $WARNINGS "|"
}

includestats() {
  # change the out separator for org-mode
  cat $BASICRESULT | tr -d "\"" | awk -F, '{print "|" $1 "|" $2 "|" ;}' -
}

genruleresults() {
  for i in {0..256} 
  do
    ITEMS=`egrep ",$i," ${RESULTSFILE} | awk -F, '{print "|" $1 "|" $3 "|" $4 "|" $5 "|" $6 "|"; }'`
    if [ ! -z "$ITEMS" ] ; then
       echo "** Rule $i"
       echo "$ITEMS" | tr -d "\"" | head -${MAXLINES}
    fi
  done
}

genreport() {
    echo "#+TITLE: DCAT Validation Report"
    echo "#+SUBTITLE: ${dcat_url}"
    echo "#+DATE: `date`"
    echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"http://www.pirilampo.org/styles/readtheorg/css/htmlize.css\"/>"
    echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"http://www.pirilampo.org/styles/readtheorg/css/readtheorg.css\"/>"
    echo "#+HTML_HEAD: <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>"
    echo "#+HTML_HEAD: <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>"
    echo "#+HTML_HEAD: <script type=\"text/javascript\" src=\"http://www.pirilampo.org/styles/lib/js/jquery.stickytableheaders.js\"></script>"
    echo "#+HTML_HEAD: <script type=\"text/javascript\" src=\"http://www.pirilampo.org/styles/readtheorg/js/readtheorg.js\"></script>"
    # echo "#+SETUPFILE: ~/SpiderOak/Org/org-html-themes/setup/theme-readtheorg.setup"
    echo "* Introduction"
    echo "Original source link: $ORIGURL"
    echo "** Processing File Links"
    echo "  - [[file:load_feed.log][~load_feed.log - loading of the DCAT file~]]"
    echo "  - [[file:basic.csv][~basic.csv~]]"
    echo "  - [[file:vodapreport.csv][~CSV Details~]]"
    echo "  - [[file:feed.$URLDATESTAMP][~feed.$DATESTAMP~]]"
    echo "  - [[file:feed.$URLDATESTAMP.report][~feed.$DATESTAMP.report~]]"
    echo "  - [[file:publishers.csv][~publishers.csv~]]"        
    echo "** Overview"
    includestats
    echo "** Statistics"
    genstatistics
    echo "* Individual Rule Results"
    genruleresults
}

genreport > $OUTPUTFILE
