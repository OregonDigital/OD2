# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Subject < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Subject
    end
  end
end
