# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class LocEthnographicTerms
      def self.expression
        %r{^http:\/\/id.loc.gov\/vocabulary\/ethnographicTerms\/.*}
      end

      def self.label(data)
        data.first['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].first['@value']
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
