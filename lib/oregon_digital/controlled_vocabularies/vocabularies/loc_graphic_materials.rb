# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class LocGraphicMaterials
      def self.expression
        %r{^http:\/\/id.loc.gov\/vocabulary\/graphicMaterials\/.*}
      end

      def self.label(data)
        data.first['http://www.w3.org/2004/02/skos/core#prefLabel'].first['@value']
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
