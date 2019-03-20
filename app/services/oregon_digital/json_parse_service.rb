# frozen_string_literal: true

module OregonDigital
  class JsonParseService
    def self.json(query)
      JSON.parse(query_response(query).body)
    end

    private

    def self.query_response
      Faraday.get(query) { |req| req.headers['Accept'] = 'application/json' }
    end
  end
end
