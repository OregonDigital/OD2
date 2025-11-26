# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class GettyAat < GettyBase
      def self.expression
        %r{^http:\/\/vocab.getty.edu\/aat\/.*}
      end
    end
  end
end
