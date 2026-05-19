# frozen_string_literal:true

module OregonDigital
  # adds error support using Redis
  module Errors
    def add_error(desc_key, message)
      Hyrax.config.redis_connection.with do |conn|
        conn.sadd(redis_key(desc_key), message)
      end
    end

    def error_keys
      Hyrax.config.redis_connection.with do |conn|
        conn.keys("#{base_error_key}:*")
      end
    end

    def all_errors
      errors = {}
      error_keys.each do |r_key|
        Hyrax.config.redis_connection.with do |conn|
          errors[shorten(r_key)] = conn.smembers(r_key)
        end
      end
      errors
    end

    def remove_errors(desc_key)
      Hyrax.config.redis_connection.with do |conn|
        conn.smembers(redis_key(desc_key)).each do |message|
          conn.srem(redis_key(desc_key), message)
        end
      end
    end

    private

    def shorten(r_key)
      r_key.split(':').last.to_sym
    end

    def redis_key(desc_key)
      "#{base_error_key}:#{desc_key}"
    end

    def base_error_key
      "hyrax:#{self.class}:#{id}:errors"
    end
  end
end
