# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class Scientific < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::OnsGenus,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsPhylum,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCommonNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsClass,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsSpecies,
          OregonDigital::ControlledVocabularies::Vocabularies::Wikidata,
          OregonDigital::ControlledVocabularies::Vocabularies::Itis,
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio,
          OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects
        ]
      end

      def fetch(*_args, &_block)
        return super unless itis_or_ubio?

        graph = fetch_from_cache(rdf_subject)
        unless graph.nil?
          persistence_strategy.graph = graph
          return self
        end
        store_statement(vocabulary.fetch(vocabulary, rdf_subject))
      rescue ControlledVocabularyFetchError
        raise ControlledVocabularyFetchError
      end

      def itis_or_ubio?
        vocabulary.to_s.include?('Itis') || vocabulary.to_s.include?('Ubio')
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
