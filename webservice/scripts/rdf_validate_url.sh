#!/bin/bash
####################################################################################

source ./log.sh

# validate if the input is RDF compliant
URL=$1
DATESTAMP=$2

cd /www/results/$DATESTAMP
FILE=feed.$DATESTAMP
STATUS=0

####################################################################################
#echo "stage1: download" 
curl -k -L -o $FILE -s -S $URL &> $FILE.download
#wget $URL -o $FILE.download -O $FILE
STATUS=$?
if [ $STATUS != 0 ] ; then 
    # echo "maybe https certificate?"   
    wget --no-check-certificate $URL -o $FILE.download -O $FILE
    if [ $? != 0 ] ; then
	STATUS=2
	log "wget failed (no https version either) $STATUS"
	exit $STATUS
    fi
fi

####################################################################################
#echo "stage2: validate rdf" 
rapper --show-namespaces --trace  -o ntriples -i guess $FILE 1> $FILE.rdf_report 2> $FILE.rdf_report2
if [ $? != 0 ] ; then 
    # echo "incorrect RDF" 1>&2
    STATUS=1
    log "rapper failed $STATUS"
fi

####################################################################################
cat $FILE.download >> $FILE.report
echo "===============================================" >> $FILE.report
cat $FILE.rdf_report2 >> $FILE.report
echo "===============================================" >> $FILE.report
cat $FILE.rdf_report >> $FILE.report

rm $FILE.download $FILE.rdf_report2 $FILE.rdf_report

log "final STATUS = $STATUS"
exit $STATUS

####################################################################################
####################################################################################
function check_status {
  if [ $? != 0 ] ; then 
	echo "stage failed"
	exit
	fi
	
}


