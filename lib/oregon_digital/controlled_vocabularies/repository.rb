# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Ethnographic Term object for storing labels and uris
    class Repository < Resource
      # Return T/F if a URI is in the vocab
      def self.in_vocab?(uri)
        valid_uri = %r{^http[s]?:\/\/vocab.getty.edu\/ulan\/.*}
        valid_uri.match?(uri)
        true
      end

      def check_all_uris(uri)
        [
          %r{^http[s]?:\/\/vocab.getty.edu\/ulan\/.*},

        ]
      end
    end
  end
end
