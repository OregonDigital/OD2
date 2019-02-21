# frozen_string_literal: true

module Qa::Authorities
  # Local Collection Name QA Object
  class LocalCollectionName < BaseAuthority
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
  end
end
