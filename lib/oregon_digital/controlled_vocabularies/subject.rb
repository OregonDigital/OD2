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
        return super unless itis?

        graph = fetch_from_cache(rdf_subject)
        unless graph.nil?
          persistence_strategy.graph = graph
          return self
        end
        store_statement(vocabulary.fetch(vocabulary, rdf_subject))
      rescue ControlledVocabularyFetchError
        raise ControlledVocabularyFetchError
      end

      def itis?
        vocabulary.to_s.include?('Itis')
      end

      def vocabulary
        @vocabulary ||= self.class.query_to_vocabulary(rdf_subject.to_s)
      end

      def fetch_from_cache(subject)
        OregonDigital::Triplestore.fetch_cached_term(subject)
      end
    end
  end
end
