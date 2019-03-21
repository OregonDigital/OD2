# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsOsuBuildings
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/osuBuildings\/.*}
      end

      def self.label(data)
        data.first['rdfs:label']['@value']
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
