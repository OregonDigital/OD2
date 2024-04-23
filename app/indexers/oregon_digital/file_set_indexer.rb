# frozen_string_literal:true

module OregonDigital
  # Indexer that indexes fileset specific metadata
  class FileSetIndexer < Hyrax::FileSetIndexer
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['oembed_url_sim'] = object.oembed_url
        # Collapse possible extracted text with OCRd text for searching
        solr_doc['all_text_timv'] = find_all_text_value(solr_doc)
        solr_doc['hocr_text_timv'] = find_hocr_text(solr_doc)
        index_additional_characterization_terms(solr_doc)
      end
    end

    def find_all_text_value(solr_doc)
      object.extracted_text&.content.presence || object&.ocr_content.presence || solr_doc['all_text_tsimv'].presence
    end

    def find_hocr_text(solr_doc)
      object&.hocr_text&.presence || solr_doc['hocr_text_tsimv'].presence
    end

    def index_additional_characterization_terms(solr_doc)
      object.characterization_terms.each do |term|
        value = object.send(term)
        solr_doc["#{term}_tesim"] = value if value.present?
      end
    end
  end
end
