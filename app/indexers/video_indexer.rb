# frozen_string_literal:true

# Indexer that video generic specific metadata
class VideoIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
    end
  end
end
