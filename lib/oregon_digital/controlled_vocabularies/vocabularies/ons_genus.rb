# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsGenus < OnsBase
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/genus\/.*}
      end
    end
  end
end
