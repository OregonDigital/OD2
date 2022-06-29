#!/bin/sh

timestamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "[$timestamp] Initializing Sidekiq (${RAILS_ENV})"

# Ensure we can write our PID
mkdir -p /data/tmp/pids
rm -f /data/tmp/pids/sidekiq.pid

#timestamp=`date +'%Y-%m-%d %H:%M:%S'`
#echo "[$timestamp] Validating database migrations"
#/data/build/validate_migrated.sh
timestamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "[$timestamp] Rebuild gems if necessary"
/data/build/install_gems.sh

# Create default roles
#timestamp=`date +'%Y-%m-%d %H:%M:%S'`
#echo "[$timestamp] Create OD Roles if necessary"
#bundle exec rails oregon_digital:create_roles

# Submit a marker to honeycomb marking the time the application starts booting
#if [ "${RAILS_ENV}" = 'production' ]; then
#  curl https://api.honeycomb.io/1/markers/${HONEYCOMB_DATASET} -X POST -H "X-Honeycomb-Team: ${HONEYCOMB_WRITEKEY}" -d "{\"message\":\"Sidekiq (${RAILS_ENV}) - ${DEPLOYED_VERSION} - booting\", \"type\":\"deploy\"}"
#fi

timestamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "[$timestamp] Starting Sidekiq ($RAILS_ENV)"
echo "   Environment: $RAILS_ENV"
echo "   Queues:      $SIDEKIQ_QUEUES"
echo "   Threads:     $SIDEKIQ_THREADS"
echo "   Log:         $SIDEKIQ_LOG"
echo "   Redis:       $REDIS_HOST:$REDIS_PORT"
echo ""
bundle exec sidekiq -c $SIDEKIQ_THREADS -e $RAILS_ENV
