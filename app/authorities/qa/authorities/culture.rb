# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Culture < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Culture
    end
  end
end
