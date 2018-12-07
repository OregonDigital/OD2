#!/bin/sh

echo "Building ${RAILS_ENV}"

rm -f tmp/pids/puma.pid
./build/install_gems.sh

# Do not auto-create SOLR or Migrations for production or staging environments
if [ "${RAILS_ENV}" != 'production' ] && [ "${RAILS_ENV}" != 'staging' ]; then
  ./build/create_solr_index.sh
  ./build/validate_migrated.sh
fi

# Precompile assets for production or staging
if [ "${RAILS_ENV}" = 'production' ] || [ "${RAILS_ENV}" = 'staging' ]; then
  curl https://api.honeycomb.io/1/markers/od2-rails-${RAILS_ENV} -X POST -H "X-Honeycomb-Team: ${HONEYCOMB_WRITEKEY}" -d "{\"message\":\"${RAILS_ENV} - ${DEPLOYED_VERSION} - compiling assets\", \"type\":\"deploy\"}"
  bundle exec rails assets:precompile
  curl https://api.honeycomb.io/1/markers/od2-rails-${RAILS_ENV} -X POST -H "X-Honeycomb-Team: ${HONEYCOMB_WRITEKEY}" -d "{\"message\":\"${RAILS_ENV} - ${DEPLOYED_VERSION} - booting\", \"type\":\"deploy\"}"
fi
