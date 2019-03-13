# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class Tgn < BaseAuthority
    self.label = lambda do |data, vocabulary|
      [vocabulary.label(data)].compact.join(', ')
    end

    def search(q)
      vocabulary = OregonDigital::ControlledVocabularies::HistoricPlace.query_to_vocabulary(q)
      if vocabulary.present?
        parse_authority_response(find_term(json(vocabulary.as_query(q)), q), vocabulary)
      else
        []
      end
    end
  end
end
