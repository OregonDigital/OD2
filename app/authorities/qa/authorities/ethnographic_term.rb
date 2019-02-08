# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class EthnographicTerm < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    class_attribute :label

    self.label = lambda do |item|
      [item.first['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].first['@value']].compact.join(', ')
    end

    def search(q)
      if OregonDigital::ControlledVocabularies::EthnographicTerm.in_vocab?(q)
        parse_authority_response(find_term(json(q), q))
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

    def find_term(response, q)
      response.select { |resp| resp['@id'] == q }
    end
  end
end
