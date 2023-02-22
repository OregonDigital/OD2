# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Ethnographic Term object for storing labels and uris
    class ExtendedLocation < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::OnsTDFFBasin
        ]
      end
    end
  end
end
