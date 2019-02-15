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

      # def each_statement
      #   rest_client.get_statements.each_statement
      # end

      def delete_statement(statement)
        rest_client.delete([statement])
      end

      # protected

      # def query_pattern(pattern, **options, &block)
      #   return enum_for(:query_pattern, pattern, options) unless block_given?
      #   Error
        # statements = pattern[:subject]
        # statements.fetch unless statements.node?
        # rest_client.insert([statements])
        # pattern[:subject]
      # end
    end
  end
end
