# frozen_string_literal:true

module OregonDigital
  # Honeycomb sampler for OD2
  class NoiseCancellingSampler
    extend Honeycomb::DeterministicSampler

    NOISY_COMMANDS = [
      'GET rails-settings-cached/v1',
      'TIME',
      'BEGIN',
      'COMMIT'
    ].freeze

    NOISY_TYPES = [
      'SCHEMA'
    ].freeze

    NOISY_PREFIXES = [
      'INCRBY',
      'TTL',
      'GET rack:',
      'SET rack:',
      'GET views/shell'
    ].freeze

    # Determine the sample rate based on the contents of the event
    #   Noisy events and events with SQL queries
    #   Redis BRPOP commands should get sampled into relative obscurity
    #     since they are happening constantly and are almost entirely
    #     uninteresting
    #   Database operations named SCHEMA
    #   Other redis commands
    # rubocop:disable Metrics/MethodLength
    def self.sample(fields)
      if (NOISY_COMMANDS & [fields['redis.command'], fields['sql.active_record.sql']]).any?
        [should_sample(100, fields['trace.trace_id']), 100]
      elsif fields['redis.command']&.start_with?('BRPOP')
        [should_sample(1000, fields['trace.trace_id']), 1000]
      elsif fields['redis.command']&.start_with?(*NOISY_PREFIXES)
        [should_sample(100, fields['trace.trace_id']), 100]
      elsif fields['sql.active_record.name']&.start_with?(*NOISY_TYPES)
        [should_sample(1000, fields['trace.trace_id']), 1000]
      else
        [true, 1]
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
