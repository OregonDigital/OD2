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

      def each(&block)
        each_statement(&block)
      end

      def each_statement(&block)
        rest_client.get_statements.each_statement(&block)
      end
    end
  end
end