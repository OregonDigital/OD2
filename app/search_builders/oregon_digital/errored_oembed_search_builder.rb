# frozen_string_literal:true

module OregonDigital
  # Finds oembed objects
  class ErroredOembedSearchBuilder < OembedSearchBuilder
    self.default_processor_chain += [:with_errored_oembed]

    def with_errored_oembed(solr_params)
      ids = OembedError.all.map(&:document_id).join(' OR ')
      solr_params[:fq] ||= []
      query = solr_params[:fq].length.zero? ? '' : ' AND '
      filter = ids.blank? ? '-id:*' : "id:(#{ids})"
      solr_params[:fq] << "#{query}#{filter}"
    end
  end
end
