# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class Tgn < BaseAuthority

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
  end
end
