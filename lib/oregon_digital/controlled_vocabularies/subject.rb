# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Subject object for storing labels and uris
    class Subject < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::GettyAat,
          OregonDigital::ControlledVocabularies::Vocabularies::Itis,
          OregonDigital::ControlledVocabularies::Vocabularies::LocGenreForms,
          OregonDigital::ControlledVocabularies::Vocabularies::LocGraphicMaterials,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::LocOrgs,
          OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuAcademicUnits,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuBuildings,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsPeople,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsSubject,
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio,
          OregonDigital::ControlledVocabularies::Vocabularies::Ulan,
          OregonDigital::ControlledVocabularies::Vocabularies::WdEntity
        ]
      end
    end
  end
end
