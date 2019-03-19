# frozen_string_literal: true

module Qa::Authorities
  # FormOfWork QA Object
  class FormOfWork < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::FormOfWork
    end
  end
end
