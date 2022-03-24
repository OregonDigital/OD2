# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Ubio
      def self.expression
        %r{.+ubio.org\/authority\/metadata.*}
      end

      def self.label(data)
        data.first.at_xpath('/rdf:RDF/rdf:Description/dc:title/text()')
      end

      def self.as_query(q)
        q
      end

      def self.fetch(vocabulary, subject)
        label = xml_parse_service.xml(vocabulary.as_query(subject.to_s)).at_xpath('/rdf:RDF/rdf:Description/dc:title/text()')
        statement(subject, label)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Net::ReadTimeout
        raise ControlledVocabularyFetchError, 'connection failed'
      end

      def self.xml_parse_service
        OregonDigital::XmlParseService
      end

      def self.statement(subject, label)
        RDF::Statement.new(subject, RDF::Vocab::SKOS.prefLabel, label)
      end
    end
  end
end
