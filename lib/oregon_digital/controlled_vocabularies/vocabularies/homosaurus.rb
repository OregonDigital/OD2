# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Homosaurus
      def self.expression
        %r{^http[s]?:\/\/homosaurus.org\/v3\/.*}
      end

      def self.label(data)
        data.first['skos:prefLabel']['@value']
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
