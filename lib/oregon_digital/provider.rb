require 'sparql/client'
require 'rdf'
require 'json/ld'
require 'uri'

module OregonDigital
  class Provider
    attr_reader :url, :sparql_client

    ##
    # @param [String] url of SPARQL endpoint
    def initialize(url)
      @http = Net::HTTP::Persistent.new(self.class)
      @url = url
      @uri = URI.parse(@url.to_s)
      @sparql_client = SPARQL::Client.new(@uri)
    end

    ##
    # Insert the provided statements into the triplestore, JSONLD allows for
    # UTF8 charset.
    # @param [RDF::Enumerable] statements to insert into triplestore
    # @return [Boolean] true if the insert was successful
    def insert(statements)
      raise(TriplestoreAdapter::TriplestoreException, "insert received an invalid array of statements") unless statements.any?

      writer = RDF::Writer.for(:jsonld)
      request = Net::HTTP::Post.new(@uri)
      request['Content-Type'] = 'application/ld+json'
      request.body = writer.dump(statements)
      @http.request(@uri, request)
      return true
    end

    ##
    # Delete the provided statements from the triplestore
    # @param [RDF::Enumerable] statements to delete from the triplestore
    # @return [Boolean] true if the delete was successful
    def delete(statements)
      raise(TriplestoreAdapter::TriplestoreException, "delete received invalid array of statements") unless statements.any?

      #TODO: Evaluate that all statements are singular, and without bnodes?
      writer = RDF::Writer.for(:jsonld)
      uri = URI.parse("#{@uri}?delete")
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/ld+json'
      request.body = writer.dump(statements)
      @http.request(uri, request)
      return true
    end

    ##
    # Returns statements matching the subject
    # @param [String] subject url
    # @return [RDF::Enumerable] RDF statements
    def get_statements(subject: nil, predicate: nil, object: nil,
                       context: nil, include_inferred: false)
      st_query = access_path_query(subject, predicate, object, context)
      uri = URI.parse(format("%{uri}?GETSTMTS#{st_query}&include_inferred=#{include_inferred}", {uri: @uri}))
      request = Net::HTTP::Get.new(uri)
      response = @http.request(uri, request)
      return RDF::Reader.for(:ntriples).new(response.body) if response.is_a? Net::HTTPSuccess
      raise RequestError.new("#{response.code}: #{response.body}\n" \
                             "Processing query #{st_query}")
    end

    ##
    # Clear all statements from the triplestore contained in the namespace
    # specified in the @uri. *BE CAREFUL*
    # @return [Boolean] true if the triplestore was cleared
    def clear_statements
      request = Net::HTTP::Delete.new(@uri)
      @http.request(@uri, request)
      return true
    end

    ##
    # Create a new namespace on the triplestore
    # @param [String] namespace to be built
    # @return [String] URI for the new namespace
    def build_namespace(namespace)
      raise(TriplestoreAdapter::TriplestoreException, "build_namespace received blank namespace") if namespace.empty?
      request = Net::HTTP::Post.new("#{build_url}/blazegraph/namespace")
      request['Content-Type'] = 'text/plain'
      request.body = "com.bigdata.rdf.sail.namespace=#{namespace}"
      @http.request(@uri, request)
      "#{build_url}/blazegraph/namespace/#{namespace}/sparql"
    end

    ##
    # Delete the namespace from the triplestore. *BE CAREFUL*
    # @param [String] namespace to be deleted
    # @return [Boolean] true if the namespace was deleted
    def delete_namespace(namespace)
      raise(TriplestoreAdapter::TriplestoreException, "delete_namespace received blank namespace") if namespace.empty?
      request = Net::HTTP::Delete.new("#{build_url}/blazegraph/namespace/#{namespace}")
      @http.request(@uri, request)
      return true
    end

    private
    def build_url
      port = ":#{@uri.port}" if @uri.port != 80
      "#{@uri.scheme}://#{@uri.host}#{port}"
    end

    def access_path_query(subject, predicate, object, context)
      str = {s: subject, p: predicate, o: object, c: context}.map do |k, v|
        v ? "#{k}=#{v.to_base}" : nil
      end.compact.join('&')
      str.empty? ? str : "&#{str}"
    end
  end
end
