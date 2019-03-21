# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsPhylum < OnsBase
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/phylum\/.*}
      end
    end
  end
end
