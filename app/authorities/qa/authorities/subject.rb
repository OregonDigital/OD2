# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Subject < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Subject
    end

    def parse_authority_response(term, vocabulary)
      resp = super(term[:response], vocabulary)
      resp.first['id'] ||= term[:q]
      resp
    end

    def find_term(response, q)
      { q: q, response: super }
    end
  end
end
