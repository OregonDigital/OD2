#!/bin/sh

# This script is intended to be used when first bringing up a production or staging cluster.
# Existing production or staging clusters have persistent volumes backing SOLR so the collection
# should not need to be created.
set -e

SOLR_HOST=$(echo $SOLR_URL | cut -d '/' -f 1,2,3)

# Upload the hyrax SOLR configurations
curl --retry 3 --retry-delay 5 --retry-connrefused -H "Content-type:application/octet-stream" --data-binary @config/solr/config.zip "${SOLR_HOST}/solr/admin/configs?action=UPLOAD&name=hyrax"

# SOLR 7.x URL to check cluster status
# Check if the target solr collection exists, create it unless a "200" is returned
STATUS_CODE=$(curl -I "${SOLR_HOST}/solr/admin/collections?action=CLUSTERSTATUS&collection=${RAILS_ENV}" 2>/dev/null | head -n 1 | cut -d ' ' -f 2)
DATA_DIR="/opt/solr/server/data/${RAILS_ENV}"

if [ "${STATUS_CODE}" != '200' ]; then
  echo "SOLR collection admin returned ${STATUS_CODE} for '${RAILS_ENV}', creating collection."
  # SOLR 7.x URL to create a collection (which includes a core)
  curl "${SOLR_HOST}/solr/admin/collections?action=CREATE&name=${RAILS_ENV}&numShards=1&collection.configName=hyrax&property.dataDir=${DATA_DIR}"
else
  echo "SOLR collection ${RAILS_ENV} exists."
  exit 0
fi
