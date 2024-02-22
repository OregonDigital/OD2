# frozen_string_literal:true

module OregonDigital
  # adds error support using Redis
  module Errors
    def add_error(desc_key, message)
      Redis.current.sadd(redis_key(desc_key), message)
    end

    def error_keys
      Redis.current.keys("#{base_error_key}:*")
    end

    def all_errors
      errors = {}
      error_keys.each do |r_key|
        errors[shorten(r_key)] = Redis.current.smembers(r_key)
      end
      errors
    end

    def remove_errors(desc_key)
      Redis.current.smembers(redis_key(desc_key)).each do |message|
        Redis.current.srem(redis_key(desc_key), message)
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
