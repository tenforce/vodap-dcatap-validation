#!/bin/sh

/config/bin/replace-env.sh /usr/local/apache2/conf/extra/httpd-vhosts.conf
/config/bin/replace-env.sh /scripts/validate.sh
/config/bin/replace-env.sh /scripts/rdf_validate.sh
/config/bin/replace-env.sh /scripts/dcat_validate.sh
/config/bin/replace-env.sh /scripts/load_feed.sh

httpd-foreground
