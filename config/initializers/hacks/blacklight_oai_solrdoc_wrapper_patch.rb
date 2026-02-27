# frozen_string_literal:true

Rails.application.config.to_prepare do
  BlacklightOaiProvider::SolrDocumentWrapper.class_eval do
    include OregonDigital::UriMethods

    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = search_service.repository.search(conditions(options))

        if limit && response.total > limit
          return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total))
        end
        # add requested urls to document
        docs = response.documents
        docs.map do |doc|
          doc_hash = doc.to_h
          doc_hash['identifier_tesim'] = construct_urls(doc)
          SolrDocument.new(doc_hash)
        end
      else
        query = search_service.search_builder.where(document_model.unique_key => selector).query
        # add requested urls to document
        doc = search_service.repository.search(query).documents.first
        doc_hash = doc.to_h
        doc_hash['identifier_tesim'] = construct_urls(doc)
        SolrDocument.new(doc_hash)
      end
    end

    def select_partial(token)
      records = search_service.repository.search(token_conditions(token)).documents
      raise ::OAI::ResumptionTokenException unless records
      # add requested urls to documents
      records = records.map do |r|
        r_hash = r.to_h
        r_hash['identifier_tesim'] = construct_urls(r)
        SolrDocument.new(r_hash)
      end
      OAI::Provider::PartialResult.new(records, token.next(token.last + limit))
    end

    def construct_urls(doc)
      assign_uris(Hyrax::SolrDocument::OrderedMembers.decorate(doc))
      [@asset_show_uri, @asset_image_uri]
    end
  end
end
