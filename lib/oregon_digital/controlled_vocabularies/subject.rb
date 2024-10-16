# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Subject object for storing labels and uris
    class Subject < Resource
      # DISABLED DUE TO SUBJECT HAVING MANY ENDPOINTS
      # rubocop:disable Metrics/MethodLength
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::BneAuthorityFile,
          OregonDigital::ControlledVocabularies::Vocabularies::GettyAat,
          OregonDigital::ControlledVocabularies::Vocabularies::Homosaurus,
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
          OregonDigital::ControlledVocabularies::Vocabularies::GettyUlan,
          OregonDigital::ControlledVocabularies::Vocabularies::Wikidata
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def fetch(*_args, &_block)
        vocabulary = self.class.query_to_vocabulary(rdf_subject.to_s)
        if vocabulary.to_s.include?('Itis')
          store_statement(vocabulary.fetch(vocabulary, rdf_subject))
        else
          super
        end
      end
    end
  end
end
