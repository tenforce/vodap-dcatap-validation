# !/bin/bash
#
# apply all substitutions for the ENV variables 
# 
#set -x

FILE=$1

#: ${ENV_LDSB_SERVICE_URL:=http://ldsb-service:81}
#: ${ENV_SUBJECTPAGES_SERVICE_URL:-http://subjectpages-service}
#: ${ENV_SPARQL_ENDPOINT_SERVICE_URL:=http://sparql-endpoint-service:8890/sparql}
#export ENV_LDSB_SERVICE_URL
#export ENV_SUBJECTPAGES_SERVICE_URL
#export ENV_SPARQL_ENDPOINT_SERVICE_URL


PARAMETERS=`env | grep ENV_`
for i in $PARAMETERS ; do
        I=`expr match "$i" '\(.*\)='`
        V=`expr match "$i" '.*=\(.*\)'`
#	echo $I
#        echo $V
	sed -i -e "s $I $V g" $FILE
done
