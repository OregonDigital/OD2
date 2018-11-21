#!/bin/sh
rm -f tmp/pids/puma.pid
./build/install_gems.sh
./build/create_solr_index.sh
./build/validate_migrated.sh
