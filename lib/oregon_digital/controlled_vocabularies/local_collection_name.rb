# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Local Collection Name object for storing labels and uris
    class LocalCollectionName < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::OnsLocalCollectionName
        ]
      end
    end
  end
end
