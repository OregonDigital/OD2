# frozen_string_literal: true

module Qa::Authorities
  # Local Collection Name QA Object
  class LocalCollectionName < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::LocalCollectionName
    end
  end
end
