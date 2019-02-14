# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Ethnographic Term object for storing labels and uris
    class EthnographicTerm < Resource
      # Return T/F if a URI is in the vocab
      configure repository: :blazegraph

      def self.in_vocab?(uri)
        valid_uri = %r{^http[s]?:\/\/id.loc.gov\/vocabulary\/ethnographicTerms\/.*}
        valid_uri.match?(uri)
      end

      def reload
        true
      end
    end
  end
end
