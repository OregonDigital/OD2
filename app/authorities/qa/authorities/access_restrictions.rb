# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class AccessRestrictions < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::AccessRestrictions
    end
  end
end
