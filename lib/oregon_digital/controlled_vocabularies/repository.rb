# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Ethnographic Term object for storing labels and uris
    class Repository < Resource
      # Return T/F if a URI is in the vocab
      def self.in_vocab?(uri)
        all_uris.each do |valid_uri|
          return true if valid_uri.match?(uri)
        end
      end

      def self.all_uris
        [
          %r{^http[s]?:\/\/vocab.getty.edu\/ulan\/.*},
          %r{^http[s]?:\/\/id.loc.gov\/authorities\/names\/.*},
          %r{^http[s]?:\/\/id.loc.gov\/authorities\/names\/.*}
        ]
      end
    end
  end
end
