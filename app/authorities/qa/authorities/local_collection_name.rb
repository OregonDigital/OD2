# frozen_string_literal: true

module Qa::Authorities
  # Local Collection Name QA Object
  class LocalCollectionName < BaseAuthority
    self.label = lambda do |item, _vocabulary|
      [item.first['rdfs:label']['@value']].compact.join(', ')
    end

    def search(q)
      vocabulary = nil
      if OregonDigital::ControlledVocabularies::LocalCollectionName.in_vocab?(q)
        parse_authority_response(find_term(json(q + '.jsonld'), q), vocabulary)
      else
        []
      end
    end

    def find_term(response, _q)
      [response]
    end
  end
end
