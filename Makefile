ROQET=roqet
DOCKER=sudo docker
GNUPLOT=gnuplot
DATAFILES=db/toLoad/catalog1.rdf
SHELL=bash
CATALOG=http://opendata.vlaanderen.be/catalog.rdf

all: vodapreport.org

genfullreports.csv: dcat-ap_validator/rules runqueries
	for i in dcat-ap_validator/rules/*.rq ; do \
          roqet -q -p http://localhost:8890/sparql -r csv -e "`cat $${i}`" ; \
      done | egrep -v Class_Name > genreports.csv

fullreport.org: genreport.sh genfullreports.csv
	./genreport.sh genreports.csv > fullreport.org

genvodapreports.csv: dcat-ap_validator/rules runqueries
	for i in vodap-rules/*.rq ; do \
          roqet -q -p http://localhost:8890/sparql -r csv -e "`cat $${i}`" ; \
      done | egrep -v Class_Name > genvodapreports.csv

genvodapreports.csv2: dcat-ap_validator/rules runqueries
	for i in test-rules/*.rq ; do \
          roqet -q -p http://localhost:8890/sparql -r json -e "`cat $${i}`" ; \
      done 

vodapreport.org: genreport.sh genvodapreports.csv
	./genreport.sh genvodapreports.csv vodapreport.org > vodapreport.org

dcat-ap_validator/rules:
	git clone https://github.com/EmidioStani/dcat-ap_validator

catalog/rdf/catalog1.rdf: 
	mkdir -p catalog/rdf
	for i in {0..80} ; do \
           wget -nc -O catalog/rdf/catalog$$i.rdf ${CATALOG}?page=$$i ; \
	done

virtuoso/dumps/all.nt: catalog/rdf/catalog1.rdf
	mkdir -p catalog/nt
	for i in {1..80} ; do \
		rapper -o ntriples catalog/rdf/catalog$$i.rdf > catalog/nt/catalog$$i.nt ; \
	done
	rm -f virtuoso/dumps/all.nt
	for i in {1..80} ; do \
		cat catalog/nt/catalog$$i.nt >> virtuoso/dumps/all.nt ; \
	done

createCatalog: virtuoso/dumps/all.nt

rmCatalog:
	rm virtuoso/dumps/all.nt
cleanCatalog: rmCatalog
	rm -rf catalog/nt/*
	rm -rf catalog/rdf/*

loadCatalog: startupvirtuoso createCatalog
	virtuoso/scripts/execute-isql.sh /data/scripts/clean_upload.sql		

        
startupvirtuoso: virtuoso/virtuoso.ini
	if [ -z startupvirtuoso ] ; then
	${DOCKER} run --name vodap-virtuoso \
	    -p 8890:8890 -p 1111:1111 \
	    -e DBA_PASSWORD=vodap \
	    -e SPARQL_UPDATE=true \
	    -e DEFAULT_GRAPH=http://data.vlaanderen.be/id/dataset/default \
	    -v `pwd`/virtuoso/:/data \
	    -d tenforce/virtuoso > startupvirtuoso 
	fi

stopvirtuoso:
	-${DOCKER} stop vodap-virtuoso
	-${DOCKER} rm vodap-virtuoso
	-rm -rf startupvirtuoso

rmvirtuoso: stopvirtuoso
	-${RM} -r virtuoso/toLoad
	-${RM} -r virtuoso

virtuoso/virtuoso.ini: config-files/virtuoso.ini
	mkdir -p virtuoso/scripts
	mkdir -p virtuoso/dumps
	cp config-files/virtuoso.ini virtuoso
	cp -r config-files/virtuoso_scripts/* virtuoso/scripts
	sed -i "s/DOCKER/${DOCKER}/" virtuoso/scripts/execute-isql.sh

realclean: rmvirtuoso
	-rm -rf genreports.csv report.org

QUERYRESULTS = query/basic.csv

.PHONY: runqueries
runqueries: ${QUERYRESULTS} 

query/%.csv: query/%.rq
	${ROQET} -q -p http://localhost:8890/sparql -r csv -e "`cat $<`" > $@

query/%.png: query/%.csv  query/%.gnuplot
	${GNUPLOT} -e "data='$<';set output 'query/${*F}.png'; set term png;" query/${*F}.gnuplot
