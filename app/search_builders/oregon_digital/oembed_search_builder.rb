# frozen_string_literal:true

module OregonDigital
  # Finds oembed objects
  class OembedSearchBuilder < Blacklight::SearchBuilder
    self.default_processor_chain = %i[with_pagination with_sorting only_oembed]

    def with_pagination(solr_params)
      solr_params[:rows] = 1000
    end

    def with_sorting(solr_params)
      solr_params[:sort] = 'system_create_dtsi desc'
    end

    def only_oembed(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << 'oembed_url_sim:*'
      solr_params[:fq] << 'has_model_ssim:*FileSet'
    end
  end
end
