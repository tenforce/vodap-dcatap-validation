#!/bin/bash

sudo docker build -t vodap .

sudo docker stop vo ;  sudo docker rm vo

sudo docker run -p80:80 -d --name vo -v /home/vagrant/OSLO/VODAP/github/vodap-dcatap-validation/webservice/logs:/logs -e ENV_LDSB_SERVICE_URL=http://ikke/ -e ENV_SPARQL_ENDPOINT_SERVICE_URL=http://13.93.84.96:8890/sparql vodap 

