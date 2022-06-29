#!/bin/sh

timestamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "[$timestamp] Initializing Sidekiq (${RAILS_ENV})"

# Ensure we can write our PID
mkdir -p /data/tmp/pids
rm -f /data/tmp/pids/sidekiq.pid

timestamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "[$timestamp] Rebuild gems if necessary"
/data/build/install_gems.sh

timestamp=`date +'%Y-%m-%d %H:%M:%S'`
echo "[$timestamp] Starting Sidekiq ($RAILS_ENV)"
echo "   Environment: $RAILS_ENV"
echo "   Queues:      $SIDEKIQ_QUEUES"
echo "   Threads:     $SIDEKIQ_THREADS"
echo "   Log:         $SIDEKIQ_LOG"
echo "   Redis:       $REDIS_HOST:$REDIS_PORT"
echo ""
bundle exec sidekiq -c $SIDEKIQ_THREADS -e $RAILS_ENV
