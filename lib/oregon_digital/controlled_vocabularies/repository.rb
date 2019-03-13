# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class Repository < Resource
      # Return Vocabulary class with matching URI regex
      def self.query_to_vocabulary(uri)
        all_endpoints.each do |endpoint|
          return endpoint if endpoint.expression.match?(uri)
        end
        nil
      end

      # Return T/F if a URI is in the vocab
      def self.in_vocab?(uri)
        query_to_vocabulary(uri).present?
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
