# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsLocalCollectionName < OnsBase
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/localCollectionName\/.*}
      end
    end
  end
end
