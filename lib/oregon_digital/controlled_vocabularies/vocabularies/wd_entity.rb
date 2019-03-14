# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class WdEntity
      def self.expression
        %r{^http[s]?:\/\/(www.)?wikidata.org\/entity\/.*}
      end

      def self.label(data)
        data.first['http://www.w3.org/2004/02/skos/core#prefLabel'].select { |label| label['@language'] == I18n.locale.to_s }.first['@value']
      end

      def self.as_query(q)
        q
      end
    end
  end
end
