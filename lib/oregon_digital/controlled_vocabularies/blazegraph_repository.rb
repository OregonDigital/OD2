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
      # def each_statement
      #   rest_client.get_statements.each_statement
      # end

      def delete_statement(statement)
        rest_client.delete([statement])
      end

      # protected

      def query_pattern(pattern, **options, &block)
        return enum_for(:query_pattern, pattern, options) unless block_given?
        enum = rest_client.get_statements(pattern.to_h).each_statement
        statements = rest_client.get_statements(pattern.to_h).each_statement
        Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Rails.logger.info pattern.to_h
        enum.each do |statement|
          block.call(statement)
        end
      end
    end
  end
end
