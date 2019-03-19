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
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio
        ]
      end

      def fetch(*_args, &_block)
        new_statement = statement
        OregonDigital::Triplestore.triplestore_client.insert([new_statement])
        self << statement
      end

      def statement
        RDF::Statement.new(rdf_subject, RDF::Vocab::SKOS.prefLabel, subject_label) 
      end

      def subject_label
        Nokogiri::XML(Faraday.get(rdf_subject).body).at_xpath("/rdf:RDF/rdf:Description/dc:title/text()")
      end
    end
  end
end

