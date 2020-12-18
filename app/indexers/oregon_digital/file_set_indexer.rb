# frozen_string_literal:true

module OregonDigital
  # Indexer that indexes fileset specific metadata
  class FileSetIndexer < Hyrax::FileSetIndexer
    # rubocop:disable Metrics/AbcSize
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['oembed_url_sim'] = object.oembed_url
        # Collapse possible extracted text with OCRd text for searching
        # Full text extraction has been returning the filename as well, so if there's only one word in the text extraction it's probably the title. Otherwise the OCR is probably good enough
        solr_doc['all_text_tsimv'] = object.ocr_content
        solr_doc['all_text_tsimv'] = solr_doc['all_text_timv'] unless solr_doc['all_text_timv'].nil? || solr_doc['all_text_timv'].first.strip.split('\n').length <= 1
        # Set bounding box information for blacklight_iiif_search
        solr_doc['all_text_bbox_tsimv'] = object.bbox_content unless object.bbox_content.nil?
        solr_doc['hocr_content_tsimv'] = object.hocr_content unless object.hocr_content.nil?
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
