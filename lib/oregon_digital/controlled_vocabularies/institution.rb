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
        return [rdf_subject.to_s] if label.to_s.blank? || rdf_label_uri_same?

        [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }]
      end

      private

      def rdf_label_uri_same?
        rdf_label.select { |lang_label| lang_label.language == I18n.locale }.first.to_s == rdf_subject.to_s
      end
    end
  end
end
