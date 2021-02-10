# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Publisher object for storing labels and uris
    class Publisher < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::Ulan,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsPublisher,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator,
          OregonDigital::ControlledVocabularies::Vocabularies::Wikidata
          OregonDigital::ControlledVocabularies::Vocabularies::LocOrgs,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuAcademicUnits
        ]
      end
    end
  end
end
