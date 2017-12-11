# !/bin/bash
#
# apply all substitutions for the ENV variables 
# 
#set -x

FILE=$1

#: ${ENV_SERVICE_URL:=http://service:81}
#export ENV_LDSB_SERVICE_URL


PARAMETERS=`env | grep ENV_`
for i in $PARAMETERS ; do
        I=`expr match "$i" '\(.*\)='`
        V=`expr match "$i" '.*=\(.*\)'`
#	echo $I
#        echo $V
	sed -i -e "s $I $V g" $FILE
done
