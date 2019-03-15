# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Scientific < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Scientific
    end
  end
end

