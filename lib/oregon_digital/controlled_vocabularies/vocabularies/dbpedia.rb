# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Dbpedia
      def self.expression
        %r{^http[s]?:\/\/dbpedia.org\/resource\/.*}
      end

      def self.label(data)
        data.first.first.second['http://www.w3.org/2000/01/rdf-schema#label'].select { |label| label['lang'] == I18n.locale.to_s }.first['value']
      end

      def self.as_query(q)
        q
      end
    end
  end
end
