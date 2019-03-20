# frozen_string_literal: true

module OregonDigital
  class JsonParseService
    def self.json(query)
      JSON.parse(query_json(query).body)
    end

    def self.query_json(query)
      Faraday.get(query) { |req| req.headers['Accept'] = 'application/json' }
    end
  end
end
