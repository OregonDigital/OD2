# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class WorkType < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::WorkType
    end
  end
end
