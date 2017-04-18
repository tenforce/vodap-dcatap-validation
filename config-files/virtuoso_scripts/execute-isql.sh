#! /bin/bash

# Takes as argument a VOS sql file and executes it
# e.g. $sh virtuoso-run-script.sh enable-auto-indexing.sql
# <virtuoso isql path> <isql port> <user> <port>

# physically installed 
# <installdir>/virtuoso/bin/isql 1111 dba dba VERBOSE=OFF 'EXEC=status()' $1 -i arg1

# TenForce docker 
# TODO: This requires the docker to have a shared volume with the scripts accessible
# 
DOCKER exec -it vodap-virtuoso /usr/local/virtuoso-opensource/bin/isql-v 1111 dba vodap VERBOSE=OFF 'EXEC=status()' $1 -i arg1


