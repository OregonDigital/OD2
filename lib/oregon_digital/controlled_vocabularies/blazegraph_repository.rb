require 'triplestore_adapter'
require 'sparql/client'

module OregonDigital
  module ControlledVocabularies
    class BlazegraphRepository < RDF::Repository
      def rest_client
        OregonDigital::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
      end

      def delete_insert(deletes, inserts)
        rest_client.delete(deletes)
        rest_client.inserts(inserts)
      end

      def each(&block)
        each_statement(&block)
      end

      def each_statement(&block)
        t = RDF::Literal("blah")
        rest_client.get_statements(subject: t, predicate: t, object: t, context: t, include_inferred: false)
      end

      def insert_statement(statement)
        rest_client.insert([statement])
      end
    end
  end
end
