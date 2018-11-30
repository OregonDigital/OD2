module OregonDigital
  # Presents oembed objects
  class OembedPresenter
    include Hyrax::ModelProxy
    attr_accessor :solr_document

    delegate :oembed_url, :human_readable_type, :to_s, to: :solr_document

    # @param [SolrDocument] solr_document
    def initialize(solr_document)
      @solr_document = solr_document
    end

    def oembed_error_history(solr_document)
      solr_document['oembed_error_history_ssim']
    end

    def oembed_last_error_date
      solr_document['oembed_last_error_date'].to_formatted_s(:rfc822)
    end
  end
end
