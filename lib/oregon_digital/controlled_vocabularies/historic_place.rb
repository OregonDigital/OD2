# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Historic Place object for storing labels and uris
    class HistoricPlace < Resource
      # Return T/F if a URI is in the vocab
      # configure repository: :blazegraph

      def self.in_vocab?(uri)
        valid_uri = %r{^http[s]?:\/\/vocab.getty.edu\/tgn\/.*}
        valid_uri.match?(uri)
      end

      def reload
        true
      end
    end
  end
end
