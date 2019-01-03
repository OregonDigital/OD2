# frozen_string_literal:true

require 'triplestore_adapter'

module OregonDigital::TriplePoweredProperties
  # Configuration to allow connection to triplestore
  class Triplestore
    ##
    # Query the graph found at the supplied uri
    #
    # @param uri [String] the uri for the graph
    # @return [RDF::Graph] the graph
    def self.fetch(uri)
      return if uri.blank?
      begin
        @triplestore ||= TriplestoreAdapter::Triplestore.new(triplestore_client)
        @triplestore.fetch(uri, from_remote: true)
      rescue TriplestoreAdapter::TriplestoreException => e
        raise e
      end
    end

    def triplestore_client
      TriplestoreAdapter::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
    end

    ##
    # Common predicates which represent labels in a graph
    def self.rdf_label_predicates
      [RDF::Vocab::SKOS.prefLabel,
       RDF::Vocab::DC.title,
       RDF::Vocab::RDFS.label,
       RDF::Vocab::SKOS.altLabel,
       RDF::Vocab::SKOS.hiddenLabel]
    end

    ##
    # Returns an array of the labels found in the supplied graph
    #
    # @param graph [RDF::Graph] the graph
    # @return [Hash<String,Array<String>>] the labels
    def self.predicate_labels(graph)
      labels = {}
      return labels if graph.nil?

      rdf_label_predicates.each do |predicate|
        labels[predicate.to_s] = []
        labels[predicate.to_s] << graph.query(predicate: predicate)
                                       .reject { |statement| statement.is_a?(Array) }
                                       .map { |statement| statement.object.to_s }
        labels[predicate.to_s].flatten!.compact!
      end
      labels
    end
  end
end
