# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsClass < OnsBase
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/class\/.*}
      end
    end
  end
end
