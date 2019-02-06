# frozen_string_literal: true

module Qa::Authorities
  # Format QA Object
  class Format < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    class_attribute :label

    self.label = lambda do |item|
      [item.first['http://www.w3.org/2000/01/rdf-schema#label'].first['@value']].compact.join(', ')
    end

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(response)
      [{ 'id' => response.first['@id'].to_s,
         'label' => label.call(response) }]
    end

    def build_query_url(q)
      query = q.split('/').map(&CGI.method(:escape)).join('/')
      "https://w3id.org/spar/mediatype/#{query}"
    end
  end
end
