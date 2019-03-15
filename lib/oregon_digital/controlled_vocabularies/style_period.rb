# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class StylePeriod < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::GettyAat,
          OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsStylePeriod
        ]
      end
    end
  end
end
