ROQET=roqet
SUDO=sudo
DOCKER=${SUDO} docker
GNUPLOT=gnuplot
SHELL=bash
CATALOG=http://opendata.vlaanderen.be/catalog.rdf
CATALOGSIMPLE=http://www.mobielvlaanderen.be/store-x/dirkt1/dataroom_dcat.rdf

all: vodapreport

# management of the reports

#genfullreports.csv: dcat-ap_validator/rules runqueries
#	for i in dcat-ap_validator/rules/*.rq ; do \
#          roqet -q -p http://localhost:8890/sparql -r csv -e "`cat $${i}`" ; \
#	done | egrep -v Class_Name > genreports.csv
#
#fullreport.org: genreport.sh genfullreports.csv
#	./genreport.sh genreports.csv > fullreport.org
#

	  #echo $${i} \

vodapreport.csv: runqueries
	for i in rules/*.rq ; do \
          roqet -q -p http://localhost:8891/sparql -r csv -e "`cat $${i}`" ; \
	done | egrep -v Class_Name > vodapreport.csv

vodapreport.org: genreport.sh vodapreport.csv
	./genreport.sh vodapreport.csv vodapreport.org > vodapreport.org

vodapreport: vodapreport.org
	${SUDO} ./docker-org-export/docker-org-export vodapreport.org 

# management of the rules
ISArules:
	mkdir -p rules
	git clone --depth=1 https://github.com/EmidioStani/dcat-ap_validator ISArules
	cp ISArules/rules/* rules

.PHONY: VODAPISArules
VODAPISArules: ISArules
	rm -rf rules
	mkdir -p rules
	./select_rules.sh ISArules VODAPISArules/VODAP_selection.csv
	./copy_rules.sh VODAPISArules

.PHONY: VODAPrules
VODAPrules: ISArules
	rm -rf rules
	mkdir -p rules
	./select_rules.sh ISArules VODAPrules/VODAP_selection.csv
	./copy_rules.sh VODAPrules



# management of the catalog


catalog/vodap/rdf/catalog1.rdf: 
	mkdir -p catalog/vodap/rdf
	for i in {0..80} ; do \
           wget -nc -O catalog/vodap/rdf/catalog$$i.rdf ${CATALOG}?page=$$i ; \
	done
	mkdir -p catalog/vodap/nt
	for i in {1..80} ; do \
		rapper -o ntriples catalog/vodap/rdf/catalog$$i.rdf > catalog/vodap/nt/catalog$$i.nt ; \
	done


catalog/simple/nt/catalog.nt: 
	mkdir -p catalog/simple/ttl
	mkdir -p catalog/simple/nt
	wget -nc -O catalog/simple/ttl/catalog.ttl ${CATALOGSIMPLE}  
	#rapper -o ntriples -i turtle catalog/simple/ttl/catalog.ttl > catalog/simple/nt/catalog.nt  
	rapper -o ntriples -i guess catalog/simple/ttl/catalog.ttl > catalog/simple/nt/catalog.nt  

virtuoso/dumps/all.nt: catalog/vodap/rdf/catalog1.rdf
	rm -f virtuoso/dumps/all.nt
	for i in {1..80} ; do \
		cat catalog/vodap/nt/catalog$$i.nt >> virtuoso/dumps/all.nt ; \
	done
virtuoso/dumps/simple.nt: catalog/simple/nt/catalog.nt
	rm -f virtuoso/dumps/simple.nt
	cp catalog/simple/nt/catalog.nt virtuoso/dumps/simple.nt 

createCatalog: virtuoso/dumps/all.nt
createCatalogS: virtuoso/dumps/simple.nt

rmCatalog:
	rm -f virtuoso/dumps/all.nt
	rm -f virtuoso/dumps/simple.nt
cleanCatalog: rmCatalog
	rm -rf catalog/vodap/nt/*
	rm -rf catalog/vodap/rdf/*
cleanCatalogS: rmCatalog
	rm -rf catalog/simple/nt/*
	rm -rf catalog/simple/ttl/*

loadCatalog: startupvirtuoso createCatalog
	virtuoso/scripts/execute-isql.sh /data/scripts/clean_upload.sql
reloadCatalog: startupvirtuoso 
	virtuoso/scripts/execute-isql.sh /data/scripts/clean_upload.sql

# management of the RDF store        
startupvirtuoso: virtuoso/virtuoso.ini
	if [ ! -f startupvirtuoso ] ; then \
	${DOCKER} run --name vodap-virtuoso \
	    -p 8891:8890 -p 1112:1111 \
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
	-rm -rf query/name*.* query/publishers.csv

# DataSets
# Used the recovered publishers list to create a query file
# for each of the publishers. The call make to generate the results
# file for the query

datasets: loadCatalog query/publishers.csv query/dataset.template
	while IFS=, read PubID Name; do \
          fn=$$(echo $${PubID} | md5sum | cut -d ' ' -f 1) ; \
	  sed -e "s@PUBID@$$PubID@g" query/dataset.template > query/name$$fn.rq ; \
          make query/name$$fn.rdf ;\
        done < query/publishers.csv

# execution of the queries
QUERYRESULTS = query/basic.csv query/publishers.csv

.PHONY: runqueries
runqueries: ${QUERYRESULTS} 

query/%.rdf: query/%.rq
	${ROQET} -q -p http://localhost:8891/sparql -r rdfxml -e "`cat $<`" > $@

query/%.csv: query/%.rq
	${ROQET} -q -p http://localhost:8891/sparql -r csv -e "`cat $<`" > $@

query/%.png: query/%.csv  query/%.gnuplot
	${GNUPLOT} -e "data='$<';set output 'query/${*F}.png'; set term png;" query/${*F}.gnuplot
