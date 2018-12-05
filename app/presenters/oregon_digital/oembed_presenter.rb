# frozen_string_literal:true

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

    def self.errors_to_html(e)
      html = "<dt>oEmbed encounted an error</dt>"
      html << "<dd>#{e.message}</dd>"
      return html.html_safe
    end
  end
end
