#!/bin/bash
# a docker run setup configuration

WORKDIR=/home/vagrant/OSLO/VODAP/github/test2

docker run -d \
    -p8891:8890 \
    -e DBA_PASSWORD=vodap \
    -e SPARQL_UPDATE=true \
    -e DEFAULT_GRAPH=http://data.vlaanderen.be/id/dataset/default \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --name vodapweb-virtuoso \
    tenforce/virtuoso


docker run  -d \
    --add-host opendata.vlaanderen.be:127.0.0.1 \
    --add-host data.vlaanderen.be:127.0.0.1      \
    -p 81:80 \
    -v $WORKDIR/logs:/logs \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e ENV_CATALOG_LOCATION=http://opendata.vlaanderen.be/catalog.rdf \
    -e ENV_VALIDATOR_DOMAIN=opendata.vlaanderen.be \
    -e ENV_VALIDATOR_LOCATION=opendata.vlaanderen.be/vodap_validator \
    -e ENV_SPARQL_ENDPOINT_SERVICE_URL=http://vodapweb-virtuoso:8890/sparql \
    --link vodapweb-virtuoso:vodapweb-virtuoso \
    --name vodap_validator \
    tenforce/vodap-dcatap-validation
      
