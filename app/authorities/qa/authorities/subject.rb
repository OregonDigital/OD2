# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Subject < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Subject
    end

    def parse_authority_response(term, vocabulary)
      [{ 'id' => term[:q],
         'label' => label.call(term[:response], vocabulary) }]
    end

    def find_term(response, q)
      { q: q, response: super }
    end
  end
end
