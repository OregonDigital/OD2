# frozen_string_literal:true

module OregonDigital
  # Indexer that indexes fileset specific metadata
  class FileSetIndexer < Hyrax::FileSetIndexer
    # rubocop:disable Metrics/AbcSize
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['oembed_url_sim'] = object.oembed_url
        # Collapse possible extracted text with OCRd text for searching
        solr_doc['all_text_tsimv'] = object.extracted_text&.content&.presence || object&.ocr_content&.presence || solr_doc['all_text_timv'].presence || solr_doc['all_text_tsimv'].presence
        # Set bounding box information for blacklight_iiif_search
        solr_doc['all_text_bbox_tsimv'] = object.bbox_content unless object.bbox_content.nil?
        solr_doc['hocr_content_tsimv'] = object.hocr_content unless object.hocr_content.nil?
        index_additional_characterization_terms(solr_doc)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def index_additional_characterization_terms(solr_doc)
      object.characterization_terms.each do |term|
        value = object.send(term)
        solr_doc["#{term}_tesim"] = value if value.present?
      end
    end
  end
end
