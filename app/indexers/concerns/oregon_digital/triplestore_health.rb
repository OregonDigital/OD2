# frozen_string_literal: true

# ts.fetch_cached_term returns nil if graph not found, otherwise graph
module OregonDigital
  # Health check for triplestore
  module TriplestoreHealth
    def triplestore_is_alive?
      triplestore.fetch_cached_term(ts_uri)
      return true
    rescue SocketError
      Rails.logger.info 'Warning: TriplestoreHealthCheck is failing'
      return false
    end

    def ts_uri
      'http://example.org/vocab/tshealth'
    end

    def triplestore
      OregonDigital::Triplestore
    end

    class TriplestoreHealthError < StandardError; end
  end
end
