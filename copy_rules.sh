#!/bin/bash

DIR=$1

HASRULES=`find $DIR -name *.rq |wc -l`
if [ ! $HASRULES = 0 ] ; then
   cp $DIR/*.rq rules
fi


