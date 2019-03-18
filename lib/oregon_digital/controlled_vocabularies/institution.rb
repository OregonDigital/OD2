# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Institution object for storing labels and uris
    class Institution < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::Dbpedia,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator
        ]
      end

      # Return a tuple of url & label
      def solrize
        label = rdf_label.select { |lang_label| lang_label.language == I18n.locale }.first
        return [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }] unless label.empty?
        super
      end
    end
  end
end
