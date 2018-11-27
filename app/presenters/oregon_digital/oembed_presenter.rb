module OregonDigital
  # Presents oembed objects
  class OembedPresenter
    include Hyrax::ModelProxy
    attr_accessor :solr_document

    delegate :oembed_url, :human_readable_type, :visibility, :to_s, to: :solr_document

    # @param [SolrDocument] solr_document
    def initialize(solr_document)
      @solr_document = solr_document
    end

    # def oembed_url
    #   solr_document.oembed_url.join(', ')
    # end
  end
end
