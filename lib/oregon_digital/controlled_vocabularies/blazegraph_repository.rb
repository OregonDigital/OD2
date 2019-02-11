module OregonDigital
  module ControlledVocabularies
    class BlazegraphRepository < RDF::Repository
      def rest_client
        TriplestoreAdapter::Client(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
      end

      def delete_insert(deletes, inserts)
        rest_client.delete(deletes)
        rest_client.inserts(inserts)
      end
    end
  end
end