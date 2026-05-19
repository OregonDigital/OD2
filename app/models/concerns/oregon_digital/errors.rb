# frozen_string_literal:true

module OregonDigital
  # adds error support using Redis
  module Errors
    def add_error(desc_key, message)
      Hyrax.config.redis_connection.sadd(redis_key(desc_key), message)
    end

    def error_keys
      Hyrax.config.redis_connection.keys("#{base_error_key}:*")
    end

    def all_errors
      errors = {}
      error_keys.each do |r_key|
        errors[shorten(r_key)] = Hyrax.config.redis_connection.smembers(r_key)
      end
      errors
    end

    def remove_errors(desc_key)
      Hyrax.config.redis_connection.smembers(redis_key(desc_key)).each do |message|
        Hyrax.config.redis_connection.srem(redis_key(desc_key), message)
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
