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
        # DBPedia doesn't seem to find its rdf_label very well, so we go looking in the statements for it
        labels = statements.select { |statement| default_labels.include?(statement.predicate) }
        label = labels.select { |lang_label| lang_label.object.try(:language) == I18n.locale }.first&.object.to_s
        # If we don't find label that way, we're either not DBPedia or fetched
        # Either way we can go forward with #rdf_label
        label = rdf_label.first if label.empty?
        return [rdf_subject.to_s] if label.to_s.blank? || rdf_label_uri_same?

        [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }]
      end

      private

      def rdf_label_uri_same?
        rdf_label.select { |lang_label| lang_label.try(:language) == I18n.locale }.first.to_s == rdf_subject.to_s
      end
    end
  end
end
