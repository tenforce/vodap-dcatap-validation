#!/bin/bash
# a docker run setup configuration

WORKDIR=/home/vagrant/OSLO/VODAP/github/test5

mkdir -p $WORKDIR

docker stop vodapweb-virtuoso 
docker stop vodap_validator 
      
docker rm vodapweb-virtuoso 
docker rm vodap_validator 
