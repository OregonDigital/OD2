# frozen_string_literal: true

module OregonDigital
  class ItisService < OddEndpointService
    def self.fetch_itis_statement(vocabulary, subject)
      statement(vocabulary, subject, itis_label(vocabulary, subject))
    end

    private

    def self.itis_label(vocabulary, subject)
      parse_json(vocabulary.as_query(subject.to_s))
    end

    def self.parse_json(query)
      json_parse_service.json(query)['scientificName']['combinedName']
    end

    def self.json_parse_service
      OregonDigital::JsonParseService
    end
  end
end