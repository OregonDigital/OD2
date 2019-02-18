require 'triplestore_adapter'
require 'sparql/client'

module OregonDigital
  module ControlledVocabularies
    class BlazegraphRepository < RDF::Repository
      def rest_client
        OregonDigital::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
      end

      def each(&block)
        return enum_for(:each) unless block_given?
        enum = rest_client.get_statements.each_statement
        enum.each do |statement|
          block.call(statement)
        end
      end

      def insert_statement(statement)
        rest_client.insert([statement])
      end

      def insert_statements(statements)
        rest_client.insert(statements)
      end

      def delete_statement(statement)
        rest_client.delete([statement])
      end
    end
  end
end
