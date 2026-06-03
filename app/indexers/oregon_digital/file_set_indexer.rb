# frozen_string_literal:true

module OregonDigital
  # Indexer that indexes fileset specific metadata
  class FileSetIndexer < Hyrax::FileSetIndexer
    def generate_solr_document
      super.tap do |solr_doc|
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
