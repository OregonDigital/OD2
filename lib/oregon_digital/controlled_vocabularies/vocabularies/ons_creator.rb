# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsCreator < OnsBase
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/creator\/.*}
      end
    end
  end
end
