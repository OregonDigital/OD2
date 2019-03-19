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

      def fetch
        OregonDigital::Triplestore.client.insert([statement])
      end

      def statement
        RDF::Statement.new(rdf_subject, RDF::SKOS.prefLabel, subject_label)
      end

      def subject_label
        Nokogiri::XML(Faraday.get(rdf_subject.gsub('\\', '')).body).at_xpath("/rdf:RDF/rdf:Description/dc:title/text()")
      end
    end
  end
end

