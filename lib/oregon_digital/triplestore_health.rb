# frozen_string_literal: true

# ts.fetch_cached_term returns nil if graph not found, otherwise graph
module OregonDigital
  # Health check for triplestore
  module TriplestoreHealth
    def triplestore_is_alive?(uri)
      return true unless triplestore.fetch_cached_term(uri).nil?

      Rails.logger.info "Warning: TriplestoreHealthCheck is failing with #{uri}"
      return false
    rescue StandardError
      Rails.logger.info "Warning: TriplestoreHealthCheck is failing with #{uri}"
      return false
    end

    def triplestore
      OregonDigital::Triplestore
    end
  end
end
