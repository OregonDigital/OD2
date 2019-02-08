# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Generic object for storing labels and uris
    class Resource < ActiveTriples::Resource
      # Validate resource is in the vocabulary
      validate :uri_in_vocab

      # Return a tuple of url & label
      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label_uri_same?
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      private

      def rdf_label_uri_same?
        rdf_label.first.to_s == rdf_subject.to_s
      end

      def uri_in_vocab
        errors.add(:uri, "URI #{id} not in vocabulary") unless self.class.respond_to?(:in_vocab?) && self.class.in_vocab?(id)
      end
    end
  end
end
