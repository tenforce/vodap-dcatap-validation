ROQET=roqet
SUDO=sudo
DOCKER=${SUDO} docker
GNUPLOT=gnuplot
SHELL=bash
CATALOG=http://opendata.vlaanderen.be/catalog.rdf

all: vodapreport.org

# management of the reports

#genfullreports.csv: dcat-ap_validator/rules runqueries
#	for i in dcat-ap_validator/rules/*.rq ; do \
#          roqet -q -p http://localhost:8890/sparql -r csv -e "`cat $${i}`" ; \
#	done | egrep -v Class_Name > genreports.csv
#
#fullreport.org: genreport.sh genfullreports.csv
#	./genreport.sh genreports.csv > fullreport.org
#

vodapreport.csv: runqueries
	for i in rules/*.rq ; do \
	  echo $${i} \
          roqet -q -p http://localhost:8890/sparql -r csv -e "`cat $${i}`" ; \
	done | egrep -v Class_Name > vodapreport.csv

vodapreport.org: genreport.sh vodapreport.csv
	./genreport.sh vodapreport.csv vodapreport.org > vodapreport.org

vodapreport: vodapreport.org
	./docker-org-export/docker-org-export vodapreport.org 

# management of the rules
ISArules:
	mkdir -p rules
	git clone --depth=1 https://github.com/EmidioStani/dcat-ap_validator ISArules
	cp ISArules/rules/* rules

.PHONY: VODAPISArules
VODAPISArules: ISArules
	rm -rf rules
	mkdir -p rules
	./select_rules.sh ISArules VODAPISArules/vodap_selection.csv
	./copy_rules.sh VODAPISArules

.PHONY: VODAPrules
VODAPrules: ISArules
	rm -rf rules
	mkdir -p rules
	./select_rules.sh ISArules VODAPrules/VODAP_selection.csv
	./copy_rules.sh VODAPrules



# management of the catalog

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

# management of the RDF store        
startupvirtuoso: virtuoso/virtuoso.ini
	if [ ! -f startupvirtuoso ] ; then \
	${DOCKER} run --name vodap-virtuoso \
	    -p 8890:8890 -p 1111:1111 \
	    -e DBA_PASSWORD=vodap \
	    -e SPARQL_UPDATE=true \
	    -e DEFAULT_GRAPH=http://data.vlaanderen.be/id/dataset/default \
	    -v `pwd`/virtuoso/:/data \
	    -d tenforce/virtuoso > startupvirtuoso ;\
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


# execution of the queries
QUERYRESULTS = query/basic.csv

.PHONY: runqueries
runqueries: ${QUERYRESULTS} 

query/%.csv: query/%.rq
	${ROQET} -q -p http://localhost:8890/sparql -r csv -e "`cat $<`" > $@

query/%.png: query/%.csv  query/%.gnuplot
	${GNUPLOT} -e "data='$<';set output 'query/${*F}.png'; set term png;" query/${*F}.gnuplot
