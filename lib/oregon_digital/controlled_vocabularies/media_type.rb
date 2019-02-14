# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Media Type object for storing labels and uris
    class MediaType < Resource
      # Return T/F if a URI is in the vocab
      configure repository: :blazegraph
      def self.in_vocab?(uri)
        valid_uri = %r{^http[s]?:\/\/w3id.org\/spar\/mediatype\/.*/.*}
        valid_uri.match?(uri)
      end
    end
  end
end
