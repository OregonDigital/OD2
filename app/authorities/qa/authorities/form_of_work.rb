# frozen_string_literal: true

module Qa::Authorities
  # FormOfWork QA Object
  class FormOfWork < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::FormOfWork
    end
  end
end
