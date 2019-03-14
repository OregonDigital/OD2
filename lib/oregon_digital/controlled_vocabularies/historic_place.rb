# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Historic Place object for storing labels and uris
    class HistoricPlace < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::GettyTgn
        ]
      end
    end
  end
end
