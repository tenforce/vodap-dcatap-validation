#!/bin/bash

# a curl version of the OSLO-Hypermedia driven pagination building block
# returning a ntriples file
# 

URL=$1
FORMAT="application/rdf+xml"
TARGET=$2

#####################################
# process link headers
#####################################
process_link_headers() {

NEXT=$1
LAST=$2


while [ ${NEXT} != ${LAST} ] ; do
    curl -D headers -o payload -k "${NEXT}"
    rapper -i guess payload >> ${TARGET}
    NEXT=`grep next headers |sed "s/^.*<//"  |sed "s/>.*$//" `
    LAST=`grep last headers |sed "s/^.*<//"  |sed "s/>.*$//" `
done

  
}
#####################################
# process hydra 
#####################################
process_hydra() {

NEXT=$1
LAST=$2


while [ ${NEXT} != ${LAST} ] ; do
    curl -D headers -o payload -k "${NEXT}"
    rapper -i guess payload > NT
    NEXT=`cat NT | grep hydra |grep next |sed "s/^.*Page>//" | sed 's/"//g' | sed -r -e 's/^\s*//' |sed -r -e 's/\s*.$//' `
    LAST=`cat NT | grep hydra |grep last |sed "s/^.*Page>//" | sed 's/"//g' | sed -r -e 's/^\s*//' |sed -r -e 's/\s*.$//' `
    cat NT >> ${TARGET}
done

}


######################################
# curl
curl -D headers -o payload -k "${URL}"

# follow the link headers if present
FIRST=`grep first headers |sed "s/^.*<//"  |sed "s/>.*$//" `
NEXT=`grep next headers |sed "s/^.*<//"  |sed "s/>.*$//" `
LAST=`grep last headers |sed "s/^.*<//"  |sed "s/>.*$//" `


if [ "${FIRST}" != "" -a "${NEXT}" != "" -a "${LAST}" != "" ] ; then
  echo "use link headers"
  rapper -i guess payload > ${TARGET}
  process_link_headers ${NEXT} ${LAST}
  exit 0;
fi

rapper -i guess payload > NT


FIRST=`cat NT | grep hydra |grep first |sed "s/^.*Page>//" | sed 's/"//g' | sed -r -e 's/^\s*//' |sed -r -e 's/\s*.$//' `
NEXT=`cat NT | grep hydra |grep next |sed "s/^.*Page>//" | sed 's/"//g' | sed -r -e 's/^\s*//' |sed -r -e 's/\s*.$//' `
LAST=`cat NT | grep hydra |grep last |sed "s/^.*Page>//" | sed 's/"//g' | sed -r -e 's/^\s*//' |sed -r -e 's/\s*.$//' `

if [ "${FIRST}" != "" -a "${NEXT}" != "" -a "${LAST}" != "" ] ; then
  echo "use hydra payload"
  cat NT > ${TARGET}
  process_hydra ${NEXT}  ${LAST}
  exit 0;
fi


echo "no pagination found - assume single respons"
rapper -i guess payload > ${TARGET}
exit 0;
