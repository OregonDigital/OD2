# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Local Collection Name object for storing labels and uris
    class LocalCollectionName < Resource
      # Return T/F if a URI is in the vocab
      def self.in_vocab?(uri)
        valid_uri = %r{^http[s]?:\/\/opaquenamespace.org\/ns\/localCollectionName\/.*}
        valid_uri.match?(uri)
      end
    end
  end
end
