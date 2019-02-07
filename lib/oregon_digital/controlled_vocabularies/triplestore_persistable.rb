# 

module OregonDigital
  module ControlledVocabularies
    included do
      def persist_uri_to_triplestore(uri)
        graph = OregonDigital::TriplePoweredProperties::Triplestore.fetch(uri)
        true
        rescue TriplestoreAdapter::TriplestoreException
          false
        end
      end
    end
  end
end