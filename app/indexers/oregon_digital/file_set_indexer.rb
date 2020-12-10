# frozen_string_literal:true

module OregonDigital
  # Indexer that indexes fileset specific metadata
  class FileSetIndexer < Hyrax::FileSetIndexer
    # rubocop:disable Metrics/AbcSize
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['oembed_url_sim'] = object.oembed_url
        solr_doc['hocr_content_tsimv'] = object.hocr_content unless object.hocr_content.nil?
        solr_doc['ocr_content_tsimv'] = object.ocr_content unless object.ocr_content.nil?
        solr_doc['all_text_tsimv'] = solr_doc['all_text_timv'] || solr_doc['ocr_content_tsimv']
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
