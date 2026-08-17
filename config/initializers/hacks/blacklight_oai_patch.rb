# frozen_string_literal:true

Rails.application.config.to_prepare do
  BlacklightOaiProvider::SolrDocumentWrapper.class_eval do
    include OregonDigital::UriMethods

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = search_service.repository.search(conditions(options))

        return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total)) if limit && response.total > limit

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
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

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



  OAI::Provider::Base.class_eval do
    # Override the process_request method to use the provider_context instance
    # instead of self.class, so the real request URL is used in error responses.
    def process_request(params = {})
      begin

        # Allow the request to pass in a url
        provider_context.url = params['url'] ? params.delete('url') : self.url

        verb = params.delete('verb') || params.delete(:verb)

        unless verb and OAI::Const::VERBS.keys.include?(verb)
          raise OAI::VerbException.new
        end

        send(methodize(verb), params)

      rescue => err
        if err.respond_to?(:code)
          OAI::Provider::Response::Error.new(provider_context, err).to_xml
        else
          raise err
        end
      end
    end
  end
end
