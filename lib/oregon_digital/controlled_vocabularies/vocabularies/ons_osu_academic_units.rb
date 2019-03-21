# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class OnsOsuAcademicUnits < OnsBase
      def self.expression
        %r{^http[s]?:\/\/opaquenamespace.org\/ns\/osuAcademicUnits\/.*}
      end
    end
  end
end
