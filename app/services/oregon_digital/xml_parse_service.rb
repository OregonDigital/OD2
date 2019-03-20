# frozen_string_literal: true

module OregonDigital
  class XmlParseService
    def self.xml(query)
      Nokogiri::XML(query_response(query).body)
    end

    private

    def query_xml(query)
      Faraday.get(query)
    end
  end
end

