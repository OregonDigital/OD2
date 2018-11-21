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
  bundle exec rails assets:precompile
fi
