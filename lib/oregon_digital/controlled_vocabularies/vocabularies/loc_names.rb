# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    class LocNames
      def self.expression
        %r{^http[s]?:\/\/id.loc.gov\/authorities\/names\/.*}
      end

      def self.label(data)
        data.first["http://www.w3.org/2004/02/skos/core#prefLabel"].first['@value']
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
