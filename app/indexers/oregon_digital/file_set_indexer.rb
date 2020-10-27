# frozen_string_literal:true

# Indexer that indexes fileset specific metadata
module OregonDigital
  class FileSetIndexer < Hyrax::FileSetIndexer
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['oembed_url_sim'] = object.oembed_url
        solr_doc['parent_id_ssi'] = object.parent.id
      end
    end
  end
end
