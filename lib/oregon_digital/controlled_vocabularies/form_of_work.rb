# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # FormOfWork object for storing labels and uris
    class FormOfWork < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::GettyAat,
          OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects,
          OregonDigital::ControlledVocabularies::Vocabularies::LocEthnographicTerms
        ]
      end
    end
  end
end
