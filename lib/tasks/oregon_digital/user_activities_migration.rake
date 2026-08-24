# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Migrate old namespaced (hyrax:*) Redis activity log keys into the current unnamespaced scheme'
  task user_activities_migration: :environment do
    # CALL: Call for redis to be used
    redis = Hyrax.config.redis_connection

    # GET: Get the old event
    old_latest_event = redis.get('hyrax:events:latest_id').to_i

    if old_latest_event.zero?
      puts 'Nothing to migrate — `hyrax:events:latest_id` not found or zero. Exiting.'
      next
    end

    # GET: Fetch latest offset of event
    new_latest_event = redis.get('events:latest_id').to_i

    puts "Offsetting old event IDs by #{new_latest_event}. Old max: #{old_latest_event}."

    # RENAME: Rename the raw event hashes - hyrax:events:N -> events:(new_event+N)
    migrated_count = 0

    (1..old_latest_event).each do |old_id|
      old_key = "hyrax:events:#{old_id}"
      next unless redis.exists?(old_key)

      new_id = new_latest_event + old_id
      redis.rename(old_key, "events:#{new_id}")
      migrated_count += 1
    end

    puts "Renamed #{migrated_count} event hash(es)."

    # COUNTER: Bump the counter only if we actually migrated something
    if migrated_count.positive?
      redis.set('`events:latest_id`', new_latest_event + old_latest_event)
      puts "`events:latest_id` set to #{new_latest_event + old_latest_event}."
    end

    # WRITE: Rewrite + merge every list key (object streams, user streams, profile streams)
    list_patterns = ['hyrax:*:event', 'hyrax:*:event:profile']

    list_patterns.each do |pattern|
      redis.scan_each(match: pattern) do |old_key|
        # GET: Get the newest first
        old_values = redis.lrange(old_key, 0, -1)
        renumbered = old_values.map { |v| (new_latest_event + v.to_i).to_s }

        new_key = old_key.sub(/\Ahyrax:/, '')

        redis.rpush(new_key, renumbered) unless renumbered.empty?
        redis.del(old_key) # Ensures reruns are safe & nothing left to re-merge

        puts "Merged and cleared #{old_key} (#{old_values.size} events) -> #{new_key}"
      end
    end

    # CLEAN: Clean up the now-empty counter key
    redis.del('hyrax:events:latest_id')

    puts 'ALL DONE.'
  end
end
