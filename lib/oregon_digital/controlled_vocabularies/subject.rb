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

      def fetch(*_args, &_block)
        vocabulary = self.class.query_to_vocabulary(rdf_subject.to_s)
        case vocabulary
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Itis'
          store_statement(fetch_itis_statement(vocabulary, rdf_subject))
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Ubio'
          store_statement(fetch_ubio_statement(vocabulary, rdf_subject))
        else
          super
        end
      end
    end
  end
end
