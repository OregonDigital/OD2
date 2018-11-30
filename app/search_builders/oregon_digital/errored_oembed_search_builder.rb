module OregonDigital
  # Finds oembed objects
  class ErroredOembedSearchBuilder < OembedSearchBuilder
    self.default_processor_chain += [:with_errored_oembed]

    def with_sorting(solr_params)
      solr_params[:sort] = 'oembed_last_error_date_dtsi desc'
    end

    def with_errored_oembed(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] = 'oembed_error_history_ssim:*'
    end
  end
end
