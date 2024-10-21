# frozen_string_literal: true

module OregonDigital
  # Collection indexer to extend Hyrax::CollectionIndexer to supper linked data
  class CollectionIndexer < Hyrax::CollectionIndexer
    include OregonDigital::IndexesLinkedMetadata
    include OregonDigital::IndexingDatesBehavior
    include OregonDigital::StripsStopwords
    include OregonDigital::ParsableLabelBehavior

    # Custom collection indexing options
    def generate_solr_document
      super.tap do |solr_doc|
        # Sortable collection title
        solr_doc['title_ssort'] = strip_stopwords(object.title.first)
        label_fetch_properties_solr_doc(object, solr_doc)
      end
    end
  end
end
