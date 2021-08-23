# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Institution < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Institution
    end

    private

    def find_term(response, q)
      return super
    end
  end
end
