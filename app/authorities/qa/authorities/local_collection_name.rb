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
      if OregonDigital::ControlledVocabularies::LocalCollectionName.in_vocab?(q)
        parse_authority_response(json(q + '.jsonld'))
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
  end
end
