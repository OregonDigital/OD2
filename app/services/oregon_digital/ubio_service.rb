# frozen_string_literal: true

module OregonDigital
  class UbioService < OddEndpointService
    def self.fetch_ubio_statement(vocabulary, subject)
      statement(subject, ubio_label(vocabulary, subject))
    end

    private

    def self.ubio_label(vocabulary, subject)
      parse_xml(vocabulary.as_query(subject.to_s))
    end

    def self.parse_xml(query)
      xml_parse_service.xml(query).at_xpath('/rdf:RDF/rdf:Description/dc:title/text()')
    end

    def self.xml_parse_service
      OregonDigital::XmlParseService
    end
  end
end