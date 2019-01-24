module OregonDigital
  module ControlledVocabularies
    # Location object
    class MediaType < ActiveTriples::Resource
      configure rdf_label: ::RDF::Vocab::DC.format

      # Return a tuple of url & label
      def solrize
        Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1"
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end
    end
  end
end