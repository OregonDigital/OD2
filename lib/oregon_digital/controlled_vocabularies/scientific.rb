# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class Scientific < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::OnsGenus,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsPhylum,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCommonNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsClass,
          OregonDigital::ControlledVocabularies::Vocabularies::WdEntity
        ]
      end
    end
  end
end

