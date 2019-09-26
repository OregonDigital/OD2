module OregonDigital
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    def visibility
      @visibility ||= self[Solrizer.solr_name(:visibility, :stored_sortable)]
    end
  end
end
