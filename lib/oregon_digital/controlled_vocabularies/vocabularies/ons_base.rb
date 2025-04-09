# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsBase
      def self.label(data)
        data.first['rdfs:label'].map {|v| v['@value'] if v['@language'] == 'en' }
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
