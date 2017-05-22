#!/bin/bash

# validate if the input is RDF compliant
URL=$1

DATESTAMP=`date +%Y-%m-%dT%H:%M:%SZ`
FILE=feed.$DATESTAMP

echo "stage1: download" 
wget $URL -o $FILE.download -O $FILE
if [ $? != 0 ] ; then 
	echo "maybe https certificate?"   
	wget --no-check-certificate $URL -o $FILE.download -O $FILE
fi

echo "stage2: validate rdf" 
rapper --show-namespaces --trace  -o ntriples -i guess $FILE 1> $FILE.rdf_report 2> $FILE.rdf_report2

cat $FILE.download >> $FILE.report
echo "===============================================" >> $FILE.report
cat $FILE.rdf_report2 >> $FILE.report
echo "===============================================" >> $FILE.report
cat $FILE.rdf_report >> $FILE.report

rm $FILE.download $FILE.rdf_report2 $FILE.rdf_report


function check_status {
 
  if [ $? != 0 ] ; then 
	echo "stage failed"
	exit
	fi
	
}
