module OregonDigital
  # Finds oembed objects
  class ErroredOembedSearchBuilder < OembedSearchBuilder
    self.default_processor_chain += [:with_errored_oembed]

    def with_errored_oembed(solr_params)
      error_ids = OembedError.all.map(&:document_id).join(' OR ')
      solr_params[:fq] ||= []
      solr_params[:fq] = "id:(#{error_ids})"
    end
  end
end
