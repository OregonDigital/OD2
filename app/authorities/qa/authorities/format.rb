# frozen_string_literal: true

module Qa::Authorities
  # Format QA Object
  class Format < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::MediaType
    end
  end
end
