# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    class OnsRepository
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/repository\/.*}
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
