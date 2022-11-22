# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class GettyUlan < GettyBase
      def self.expression
        %r{^http[s]?:\/\/vocab.getty.edu\/ulan\/.*}
      end
    end
  end
end
