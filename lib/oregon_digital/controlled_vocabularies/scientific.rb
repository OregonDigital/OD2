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
          OregonDigital::ControlledVocabularies::Vocabularies::WdEntity,
          OregonDigital::ControlledVocabularies::Vocabularies::Itis,
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio
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
