#!/bin/sh
set -e

if [ "${RAILS_ENV}" = 'production' ]; then
  echo "Cannot auto-create SOLR collection for ${RAILS_ENV}, exiting"
  exit 1
fi

SOLR_HOST=$(echo $SOLR_URL | cut -d '/' -f 1,2,3)

# SOLR 6.x URL to check cluster status
# Check if the target solr collection exists, create it unless a "200" is returned
STATUS_CODE=$(curl -I "${SOLR_HOST}/solr/admin/collections?action=CLUSTERSTATUS&collection=${RAILS_ENV}" 2>/dev/null | head -n 1 | cut -d ' ' -f 2)

if [ "${STATUS_CODE}" != '200' ]; then
  echo "SOLR collection admin returned ${STATUS_CODE} for '${RAILS_ENV}', creating collection."
  # Upload the hyrax SOLR configurations
  curl -H "Content-type:application/octet-stream" --data-binary @config/solr/config.zip "${SOLR_HOST}/solr/admin/configs?action=UPLOAD&name=hyrax"
  # SOLR 6.x URL to create a collection (which includes a core)
  curl "${SOLR_HOST}/solr/admin/collections?action=CREATE&name=${RAILS_ENV}&numShards=1&collection.configName=hyrax"
else
  echo "SOLR collection ${RAILS_ENV} exists."
  exit 0
fi
