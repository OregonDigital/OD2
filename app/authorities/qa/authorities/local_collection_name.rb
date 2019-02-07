# frozen_string_literal: true

module Qa::Authorities
  # Local Collection Name QA Object
  class LocalCollectionName < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    class_attribute :label

    self.label = lambda do |item|
      [item['rdfs:label']['@value']].compact.join(', ')
    end

    def search(q)
      valid_uri = %r{http[s]?:\/\/opaquenamespace.org\/ns\/localCollectionName\/(.*)}
      if (match = valid_uri.match(q))
        parse_authority_response(json(build_query_url(match.captures[0])))
      else
        []
      end
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(response)
      [{ 'id' => response['@id'].to_s,
         'label' => label.call(response) }]
    end

    def build_query_url(q)
      "http://opaquenamespace.org/ns/localCollectionName/#{q}.jsonld"
    end
  end
end
