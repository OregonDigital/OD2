#!/bin/sh

echo "Starting tools container ${RAILS_ENV}"

# Get setup to be able to do stuff
./build/install_gems.sh

# Sleep forever, sweet container
while `true`; do
   sleep 600
done
