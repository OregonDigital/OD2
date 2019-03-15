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
        label = rdf_label.select { |label| label.language == I18n.locale }.first
        label ||= rdf_label.first
        return [rdf_subject.to_s] if label.to_s.blank? || rdf_label_uri_same?
        [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }]
      end
    end
  end
end
