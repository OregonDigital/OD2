# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class Tgn < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    class_attribute :label

    self.label = lambda do |item|
      [item.first['http://www.w3.org/2000/01/rdf-schema#label'].first['@value']].compact.join(', ')
    end

    def search(q)
      if OregonDigital::ControlledVocabularies::HistoricPlace.in_vocab?(q)
        parse_authority_response(json(q + '.jsonld'))
      else
        []
      end
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(term)
      [{ 'id' => term.first['@id'].to_s,
         'label' => label.call(term) }]
    end
  end
end
