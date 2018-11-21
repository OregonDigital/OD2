#!/bin/sh

if [ "${RAILS_ENV}" = 'production' ] || [ "${RAILS_ENV}" = 'staging' ]; then
  echo "Cannot auto-install gems in ${RAILS_ENV}, exiting"
  exit 1
fi

bundle install
