# frozen_string_literal:true

# Indexer that indexes generic specific metadata
class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
    end
  end
end
