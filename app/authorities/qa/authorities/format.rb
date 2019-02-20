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

    # Repsonse can be found here http://www.sparontologies.net/mediatype/text/css.json
    # Sparontologies has been returning inconsistent data on where the id is placed,
    # so this accounts for it being in the two possible spots
    def find_response_id(response)
      response.first['@id'].blank? ? response.second['@id'] : response.first['@id']
    end

    # Response can be found here http://www.sparontologies.net/mediatype/text/css.json
    def find_response_label(response)
      response.second['http://www.w3.org/2000/01/rdf-schema#label'].first['@value']
    end
  end
end
