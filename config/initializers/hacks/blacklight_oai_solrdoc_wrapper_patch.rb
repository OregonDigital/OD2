# frozen_string_literal:true

Rails.application.config.to_prepare do
  BlacklightOaiProvider::SolrDocumentWrapper.class_eval do
    include OregonDigital::UriMethods

    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = @controller.repository.search(conditions(options))

        if limit && response.total > limit
          return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total))
        end
        # add requested urls to document
        docs = response.documents
        docs.each do |doc|
          doc['identifier_tesim'] = construct_urls(doc)
        end
        docs
      else
        query = @controller.search_builder.where(document_model.unique_key => selector).query
        # add requested urls to document
        doc = @controller.repository.search(query).documents.first
        doc['identifier_tesim'] = construct_urls(doc)
        doc
      end
    end

    def select_partial(token)
      records = @controller.repository.search(token_conditions(token)).documents
      raise ::OAI::ResumptionTokenException unless records
      # add requested urls to documents
      records.each do |r|
        r['identifier_tesim'] = construct_urls(r)
      end
      OAI::Provider::PartialResult.new(records, token.next(token.last + limit))
    end

    def construct_urls(doc)
      assign_uris(Hyrax::SolrDocument::OrderedMembers.decorate(doc))
      [@asset_show_uri, @asset_image_uri]
    end
  end
end
