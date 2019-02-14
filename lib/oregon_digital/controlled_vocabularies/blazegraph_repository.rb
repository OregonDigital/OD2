require 'triplestore_adapter'
require 'sparql/client'

module OregonDigital
  module ControlledVocabularies
    class BlazegraphRepository < RDF::Repository
      def rest_client
        OregonDigital::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
      end

      def each(&block)
        each_statement(&block)
      end

      def insert_statement(statement)
        rest_client.insert([statement])
      end

      def each_statement(&block)
        rest_client.get_statements.each_statement(&block)
      end

      def insert_statement(statement)
        rest_client.insert([statement])
      end

      def query(subject)
        statements = subject[:subject].fetch
        rest_client.insert([statements])
        subject[:subject]
      end
    end
  end
end
