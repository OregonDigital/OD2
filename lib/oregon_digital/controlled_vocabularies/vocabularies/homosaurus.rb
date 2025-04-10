# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Homosaurus
      def self.expression
        %r{^http[s]?:\/\/homosaurus.org\/v4\/.*}
      end

      def self.label(data)
        labels = data.first['skos:prefLabel']

        if labels.is_a?(Array)
          labels.map { |v| v['@value'] if v['@language'] == 'en' }.first
        else
          labels['@value']
        end
      end

      def self.as_query(q)
        q + '.jsonld'
      end
    end
  end
end
