# frozen_string_literal: true

module OregonDigital
  class XmlParseService
    def self.xml(query)
      Nokogiri::XML(query_xml(query).body)
    end

    def self.query_xml(query)
      Faraday.get(query)
    end
  end
end
