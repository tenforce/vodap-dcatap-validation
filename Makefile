ROQET=roqet
DOCKER=docker
GNUPLOT=gnuplot
DATAFILES=db/toLoad/catalog1.rdf
SHELL=bash

all: report.org

genreports.csv: dcat-ap_validator/rules startupvirtuoso runqueries
	for i in dcat-ap_validator/rules/*.rq ; do \
          roqet -q -p http://localhost:8890/sparql -r csv -e "`cat $${i}`" ; \
      done | egrep -v Class_Name > genreports.csv

report.org: genreport.sh genreports.csv
	./genreport.sh genreports.csv > report.org

dcat-ap_validator/rules:
	git clone https://github.com/EmidioStani/dcat-ap_validator

db/toLoad/catalog1.rdf: 
	mkdir -p db/toLoad
	for i in {0..80} ; do \
           wget -nc -O db/toLoad/catalog$$i.rdf http://opendata.vlaanderen.be/catalog.rdf?page=$$i ; \
	done

startupvirtuoso: ${DATAFILES} db/virtuoso.ini
	${DOCKER} run --name my-virtuoso -p 8890:8890 -p 1111:1111 \
	    -e DBA_PASSWORD=myDbaPassword -e SPARQL_UPDATE=true \
	    -e DEFAULT_GRAPH=http://www.example.com/my-graph \
	    -v `pwd`/db:/data -d tenforce/virtuoso > startupvirtuoso
	sleep 180

stopvirtuoso:
	-${DOCKER} stop my-virtuoso
	-${DOCKER} rm my-virtuoso
	-rm -rf startupvirtuoso

rmvirtuoso: stopvirtuoso
	-${RM} -r db/toLoad
	-${RM} -r db

db/virtuoso.ini: config-files/virtuoso.ini
	mkdir -p db
	cp config-files/virtuoso.ini db

realclean: rmvirtuoso
	-rm -rf genreports.csv report.org

QUERYRESULTS = query/basic.csv

.PHONY: runqueries
runqueries: ${QUERYRESULTS} 

query/%.csv: query/%.rq
	${ROQET} -q -p http://localhost:8890/sparql -r csv -e "`cat $<`" > $@

query/%.png: query/%.csv  query/%.gnuplot
	${GNUPLOT} -e "data='$<';set output 'query/${*F}.png'; set term png;" query/${*F}.gnuplot
