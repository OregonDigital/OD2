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
      if OregonDigital::ControlledVocabularies::MediaType.in_vocab?(q)
        parse_authority_response(json(q))
      else
        []
      end
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(response)
      [{ 'id' => response.first['@id'].to_s,
         'label' => label.call(response) }]
    end
  end
end
