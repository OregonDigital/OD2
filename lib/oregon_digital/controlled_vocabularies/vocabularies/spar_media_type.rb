# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class SparMediaType
      def self.expression
        %r{^https:\/\/w3id.org\/spar\/mediatype\/.*/.*}
      end

      def self.label(data)
        data.first['http://www.w3.org/2000/01/rdf-schema#label'].first['@value']
      end

      def self.as_query(q)
        q
      end
    end
  end
end
