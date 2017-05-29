#!/bin/bash

function log() {
    ( echo -n "[" ; echo -n `date` ; echo -n "] " ; echo $* ) >> /logs/validate.log
}
