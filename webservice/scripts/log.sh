#!/bin/bash
####################################################################################
# title:       log.sh
# description: make sure that the log messages contain the name of the
#              script which issues them (file needs to be 'sourced')
# 

scriptname=$(basename $0)
function log() {
    ( echo -n "[" ; echo -n `date` ; echo -n "] " ; echo $scriptname $* ) >> /logs/webservice.log
}

# Dump file into logfile (limit the size!)

function log_file() {
    ( echo -n "[" ; echo -n `date` ; echo -n "] " ; echo $scriptname START ; cat $1 ; echo "END" ) >> /logs/webservice.log
}

####################################################################################
####################################################################################
