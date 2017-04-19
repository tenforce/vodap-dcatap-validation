#!/usr/bin/env bash
#################################################################
echo "*** Running Application_bootstrap.sh ****"

# the application dependencies deployment.

apt-get install -y rasqal-utils raptor2-utils gnuplot

# a tool to generate the html pages
git clone https://github.com/binarin/docker-org-export.git 

# the generic DCAT-AP queries
git clone --depth=1 https://github.com/EmidioStani/dcat-ap_validator ISArules

#################################################################
# startup the services

make startupvirtuoso


