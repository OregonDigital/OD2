#!/bin/sh

echo "Starting tools container ${RAILS_ENV}"

# Get setup to be able to do stuff
echo "Installing gems..."
./build/install_gems.sh

# Start init
echo "Starting init"
exec /sbin/init

# Sleep forever, sweet container
#while `true`; do
#   sleep 600
#done
