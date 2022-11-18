# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class GettyBase
      def self.label(data)
        term = data.first['identified_by'].select do |identifier|
          identifier['classified_as'].any? do |classification|
            classification['id'] == 'http://vocab.getty.edu/term/type/Descriptor'
          end
        end
        term.first['content']
        # data.first['http://www.w3.org/2000/01/rdf-schema#label'].first['@value']
      end

      def self.as_query(q)
        q + '.json'
      end
    end
  end
end
