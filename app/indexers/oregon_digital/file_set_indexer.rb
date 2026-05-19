# frozen_string_literal:true

module OregonDigital
  # Indexer that indexes fileset specific metadata
  class FileSetIndexer < Hyrax::FileSetIndexer

    # @param [#create_date, #modified_date, #has_model, #id, #to_json, #attached_files, #[]] obj
    # The class of obj must respond to these methods:
    #   inspect
    #   outgoing_reflections
    def initialize(obj)
      @object = obj.is_a?(Hash) ? Wings::ActiveFedoraConverter.new(resource: obj[:resource]).convert : obj
    end

    def to_solr
      # This is a temporary bridge between AF and Valkyrie indexing
      # This whole file should be removed once OD2 has proper valkyrie indexing support
      self.generate_solr_document.tap do |solr_doc|
        solr_doc['oembed_url_sim'] = object.oembed_url
        # Collapse possible extracted text with OCRd text for searching
        solr_doc['all_text_timv'] = find_all_text_value
        solr_doc['hocr_text_timv'] = find_hocr_text
        index_additional_characterization_terms(solr_doc)
        # Add in an indexing to accessibility_feature
        accessibility_label(solr_doc, object)
      end
    end

    def find_all_text_value
      object.extracted_text&.content.presence
    end

    def find_hocr_text
      object.hocr_text
    end

    def index_additional_characterization_terms(solr_doc)
      object.characterization_terms.each do |term|
        value = object.send(term)
        solr_doc["#{term}_tesim"] = value if value.present?
      end
    end

    # METHOD: Create index for accessibility feature
    def accessibility_label(solr_doc, object)
      feature_labels = OregonDigital::AccessibilityFeatureService.new.all_labels(object.accessibility_feature)
      solr_doc['accessibility_feature_label_sim'] = feature_labels
      solr_doc['accessibility_feature_label_ssim'] = feature_labels
      solr_doc['accessibility_feature_label_tesim'] = feature_labels
    end
  end
end
