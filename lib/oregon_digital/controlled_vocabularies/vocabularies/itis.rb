# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Itis
      def self.expression
        %r{^http[s]?:\/\/www.itis.gov\/servlet\/SingleRpt\/SingleRpt\?search_topic=TSN&search_value=(.*)}
      end

      def self.label(data)
        data.first['scientificName']['combinedName']
      end

      def self.as_query(q)
        tsn = expression.match(q).captures.first
        "https://www.itis.gov/ITISWebService/jsonservice/getFullRecordFromTSN?tsn=#{tsn}"
      end

      def self.fetch(vocabulary, subject)
        label = json_parse_service.json(vocabulary.as_query(subject.to_s))['scientificName']['combinedName']
        statement(subject, label)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Net::ReadTimeout
        raise ControlledVocabularyFetchError, 'connection failed'
      end

      def self.json_parse_service
        OregonDigital::JsonParseService
      end

      def self.statement(subject, label)
        RDF::Statement.new(subject, RDF::Vocab::SKOS.prefLabel, label)
      end
    end
  end
end
