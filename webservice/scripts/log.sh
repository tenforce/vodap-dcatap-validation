#!/bin/bash

scriptname=$(basename $0)

function log() {
    ( echo -n "[" ; echo -n `date` ; echo -n "] " ; echo $scriptname $* ) >> /logs/webservice.log
}
