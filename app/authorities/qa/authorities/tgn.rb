# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class Tgn < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::HistoricPlace
    end
  end
end
