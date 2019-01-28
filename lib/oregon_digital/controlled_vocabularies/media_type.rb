module OregonDigital
  module ControlledVocabularies
    class MediaType < ActiveTriples::Resource
      configure rdf_label: ::RDF::Vocab::DC.format

      # Return a tuple of url & label
      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      def append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
        return super unless object.controlled_properties.include?(solr_field_key.to_sym)

        Rails.logger.info '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        Rails.logger.info val
        case val
        when ActiveTriples::Resource
          append_label_and_uri(solr_doc, solr_field_key, field_info, val)
        when String
          append_label(solr_doc, solr_field_key, field_info, val)
        else
          raise ArgumentError, "Can't handle #{val.class}"
        end
      end
    end
  end
end