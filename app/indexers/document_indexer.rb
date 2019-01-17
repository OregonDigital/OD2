# frozen_string_literal:true

# Indexer that indexes document specific metadata
class DocumentIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
    end
  end
end
