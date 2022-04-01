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
          OregonDigital::ControlledVocabularies::Vocabularies::Wikidata,
          OregonDigital::ControlledVocabularies::Vocabularies::Itis,
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio
        ]
      end

      def fetch(*_args, &_block)
        vocabulary = self.class.query_to_vocabulary(rdf_subject.to_s)
        if vocabulary.to_s.include?('Itis') || vocabulary.to_s.include?('Ubio')
          store_statement(vocabulary.fetch(vocabulary, rdf_subject)) unless in_triplestore?
        else
          super
        end
      rescue ControlledVocabularyFetchError
        raise ControlledVocabularyFetchError
      end
    end
  end
end
