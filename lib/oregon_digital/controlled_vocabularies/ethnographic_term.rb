# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Ethnographic Term object for storing labels and uris
    class EthnographicTerm < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::LocEthnographicTerms
        ]
      end
    end
  end
end
