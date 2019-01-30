# frozen_string_literal:true

# Indexer that image generic specific metadata
class ImageIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
    end
  end
end
