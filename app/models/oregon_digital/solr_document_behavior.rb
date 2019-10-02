# frozen_string_literal:true

module OregonDigital
  # Custom SolrDocument behaviors
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    # OVERRIDE FROM HYRAX: to simplify visibility getter
    def visibility
      @visibility ||= self[Solrizer.solr_name(:visibility, :stored_sortable)]
    end
  end
end
