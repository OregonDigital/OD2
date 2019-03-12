# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Ethnographic Term object for storing labels and uris
    class Repository < Resource
      # Return T/F if a URI is in the vocab
      def self.query_to_vocabulary(uri)
        all_endpoints.each do |endpoint|
          return endpoint if endpoint.expression.match?(uri)
        end
        nil
      end

      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::Ulan,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsRepository
        ]
      end
    end
  end
end
