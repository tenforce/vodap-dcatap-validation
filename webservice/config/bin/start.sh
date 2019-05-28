#!/bin/sh

/config/bin/replace-env.sh /usr/local/apache2/conf/extra/httpd-vhosts.conf
/config/bin/replace-env.sh /scripts/validate.sh
/config/bin/replace-env.sh /scripts/rdf_validate_url.sh
/config/bin/replace-env.sh /scripts/dcat_validate.sh
/config/bin/replace-env.sh /scripts/dcatapvl_recommended_validate.sh
/config/bin/replace-env.sh /scripts/dcatapvl_mandatory_validate.sh
/config/bin/replace-env.sh /scripts/dereference.sh
/config/bin/replace-env.sh /scripts/load_feeds.sh
/config/bin/replace-env.sh /scripts/datasets.sh
/config/bin/replace-env.sh /scripts/genreport.sh
/config/bin/replace-env.sh /scripts/datasets-list-before.html

/config/bin/replace-env.sh /www/index.html
/config/bin/replace-env.sh /www/minimal.html
/config/bin/replace-env.sh /www/vodap.html

touch /logs/webservice.log
chmod 666 /logs/webservice.log

httpd-foreground
