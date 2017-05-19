#!/bin/sh

/config/bin/replace-env.sh /usr/local/apache2/conf/extra/httpd-vhosts.conf

httpd-foreground
