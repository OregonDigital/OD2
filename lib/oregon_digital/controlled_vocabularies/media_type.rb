module OregonDigital
  module ControlledVocabularies
    class MediaType < ActiveTriples::Resource
      configure rdf_label: ::RDF::Vocab::DC.format

      # Return a tuple of url & label
      def solrize
        Rails.logger.info '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        Rails.logger.info val
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      def append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
        Rails.logger.info '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        Rails.logger.info val
        super
      end
    end
  end
end