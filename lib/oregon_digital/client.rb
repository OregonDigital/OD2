require 'rdf'
require 'uri'

module OregonDigital
  class Client
    attr_reader :provider, :url

    ##
    # @param [String] provider_name string of the TriplestoreAdapter::Providers:: to use as the triplestore
    # @param [String] url to the triplestore endpoint related to the provider type
    def initialize(provider_name, url)
      raise TriplestoreAdapter::TriplestoreException.new("#{url} is not a valid URI") unless url =~ URI::DEFAULT_PARSER.regexp[:ABS_URI]
      @url = url

      klass = Object.const_get("OregonDigital::Provider")
      @provider = klass.new(@url)
    end

    ##
    # Insert provided statements into the triplestore
    # @param [RDF::Enumerable] statements
    # @raise [TriplestoreAdapter::TriplestoreException] if the provider doesn't implement this method
    def insert(statements)
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing insert method.") unless @provider.respond_to?(:insert)
      @provider.insert(statements)
    end

    ##
    # Delete provided statements from the triplestore
    # @param [RDF::Enumerable] statements
    # @raise [TriplestoreAdapter::TriplestoreException] if the provider doesn't implement this method
    def delete(statements)
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing delete method.") unless @provider.respond_to?(:delete)
      @provider.delete(statements)
    end

    ##
    # Get statements from the server
    # @param [String] subject url
    # @raise [TriplestoreAdapter::TriplestoreException] if the provider doesn't implement this method
    def get_statements(subject: nil, predicate: nil, object: nil, context: nil, include_inferred: false, graph_name: nil)
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing get_statements method.") unless @provider.respond_to?(:get_statements)
      @provider.get_statements(subject: subject, predicate: predicate, object: object, context: context, include_inferred: include_inferred)
    end

    ##
    # Clear all statements from the triplestore contained in the
    # namespace/context specified in the providers url. *BE CAREFUL*
    # @raise [TriplestoreAdapter::TriplestoreException] if the provider doesn't implement this method
    def clear_statements
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing clear_statements method.") unless @provider.respond_to?(:clear_statements)
      @provider.clear_statements
    end
  end
end
