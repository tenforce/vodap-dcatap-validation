#!/bin/bash
RESULTSFILE=genreports.csv

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
       echo "$ITEMS"
    fi
  done
}

genreport() {
  echo "#+TITLE: DCAT Vvalidation Report (catalog.rdf file)"
  echo "#+SETUPFILE: ~/SpiderOak/Org/org-html-themes/setup/theme-readtheorg.setup"
  echo "* Introduction"
  includestats
  echo "* Statistics"
  genstatistics
  echo "* Individual Rule Results"
  genruleresults
}

genreport > report.org
