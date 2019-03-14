# frozen_string_literal: true

module Qa::Authorities
  # Local Collection Name QA Object
  class LocalCollectionName < BaseAuthority
    self.label = lambda do |data, vocabulary|
      [vocabulary.label(data)].compact.join(', ')
    end

    def search(q)
      vocabulary = OregonDigital::ControlledVocabularies::LocalCollectionName.query_to_vocabulary(q)
      if vocabulary.present?
        parse_authority_response(find_term(json(vocabulary.as_query(q)), q), vocabulary)
      else
        []
      end
    end

    def find_term(response, _q)
      [response]
    end
  end
end
