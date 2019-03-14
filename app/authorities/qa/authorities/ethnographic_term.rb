# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class EthnographicTerm < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::EthnographicTerm
    end
  end
end
