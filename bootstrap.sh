#!/usr/bin/env bash
#################################################################
echo "*** Running Bootstrap.sh ****"

apt-get install -y emacs docker docker-compose dos2unix
apt-get install -y rasqal-utils

git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
