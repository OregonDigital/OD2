# frozen_string_literal:true

Rails.application.config.to_prepare do
  BlacklightOaiProvider::SolrDocumentWrapper.class_eval do
    include OregonDigital::UriMethods
    def search_service
      @controller.search_service
    end
    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = search_service.repository.search(conditions(options))

        if limit && response.total > limit
          return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total))
        end
        # overwrite identifier_tesim with show page and thumb urls
        docs = response.documents
        docs.each do |doc|
          doc['identifier_tesim'] = construct_urls(doc)
        end
        docs
      else
        query = search_service.search_builder.where(id: selector).query
        # overwrite identifier_tesim with show page and thumb urls
        doc = search_service.repository.search(query).documents.first
        doc['identifier_tesim'] = construct_urls(doc)
        doc
      end
    end

    def construct_urls(doc)
      assign_uris(doc)
      [@asset_show_uri, @asset_image_uri]
    end
  end
end
