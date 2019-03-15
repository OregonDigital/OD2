# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class Culture < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::GettyAat,
          OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCulture,
        ]
      end
    end
  end
end
