# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Media Type object for storing labels and uris
    class MediaType < ActiveTriples::Resource
      # Return a tuple of url & label
      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label_uri_same?
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      private

      def rdf_label_uri_same?
        rdf_label.first.to_s == rdf_subject.to_s
      end
    end
  end
end
