# frozen_string_literal: true

module Qa::Authorities
  # Format QA Object
  class Format < BaseAuthority
    self.label = lambda do |item, _vocabulary|
      [item.first['http://www.w3.org/2000/01/rdf-schema#label'].first['@value']].compact.join(', ')
    end

    def search(q)
      vocabulary = nil
      if OregonDigital::ControlledVocabularies::MediaType.in_vocab?(q)
        parse_authority_response(find_term(json(q), q), vocabulary)
      else
        []
      end
    end
  end
end
