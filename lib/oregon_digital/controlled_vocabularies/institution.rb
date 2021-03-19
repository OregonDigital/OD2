# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Institution object for storing labels and uris
    class Institution < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator
        ]
      end
    end
  end
end
