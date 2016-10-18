#!/usr/bin/env bash
#################################################################
echo "*** Running Bootstrap.sh ****"

apt-get install -y emacs dos2unix
apt-get install -y rasqal-utils git emacs vim

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-engine

systemctl status docker

groupadd docker
usermod -aG docker vagrant

git clone https://github.com/binarin/docker-org-export.git /usr/local/docker-org-import

git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
