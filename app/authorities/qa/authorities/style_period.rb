# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class StylePeriod < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::StylePeriod
    end
  end
end
