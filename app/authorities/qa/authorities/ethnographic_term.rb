# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class EthnographicTerm < BaseAuthority
    self.label = lambda do |item, vocabulary|
      [item.first['http://www.loc.gov/mads/rdf/v1#authoritativeLabel'].first['@value']].compact.join(', ')
    end

    def search(q)
      vocabulary = nil
      if OregonDigital::ControlledVocabularies::EthnographicTerm.in_vocab?(q)
        parse_authority_response(find_term(json(q), q), vocabulary)
      else
        []
      end
    end
  end
end
