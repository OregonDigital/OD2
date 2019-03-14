# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class Publisher < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::Ulan,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsRepository,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator
        ]
      end
    end
  end
end
