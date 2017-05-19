#!/bin/bash

# validate if the input is RDF compliant
FILE=$1

rapper --show-namespaces --trace  -o ntriples -i guess $FILE > $FILE.rdf_report
