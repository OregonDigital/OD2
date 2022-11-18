# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Publisher < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Publisher
    end
  end
end
