# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Repository < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Repository
    end
  end
end
