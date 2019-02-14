# frozen_string_literal: true

module Qa::Authorities
  # Format QA Object
  class Format < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    class_attribute :label

    self.label = lambda do |item|
      [item].compact.join(', ')
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
      id = find_response_id(response)
      parsed_label = find_response_label(response)
      [{ 'id' => id,
         'label' => label.call(parsed_label) }]
    end

    def find_response_id(response)
      response.first['@id'] || response.second['@id'] 
    end

    def find_response_label(response)
      response.second['http://www.w3.org/2000/01/rdf-schema#label'].first['@value'] 
    end
  end
end
