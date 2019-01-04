# frozen_string_literal:true

# Indexer that indexes audio specific metadata
class AudioIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
    end
  end
end
