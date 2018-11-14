require 'triplestore_adapter'

module OregonDigital::TriplePoweredProperties
  class Triplestore
    ##
    # Query the graph found at the supplied uri
    #
    # @param uri [String] the uri for the graph
    # @return [RDF::Graph] the graph
    def self.fetch(uri)
      unless uri.blank?
        begin
          @triplestore ||= TriplestoreAdapter::Triplestore.new(TriplestoreAdapter::Client.new(ENV["SCHOLARSARCHIVE_TRIPLESTORE_ADAPTER_TYPE"] || "blazegraph",
                                                      ENV["SCHOLARSARCHIVE_TRIPLESTORE_ADAPTER_URL"] || 'http://localhost:9999/blazegraph/namespace/development/sparql'))
          @triplestore.fetch(uri, from_remote: true)
        rescue TriplestoreAdapter::TriplestoreException => e
          raise e
        end
      end
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

      self.rdf_label_predicates.each do |predicate|
        labels[predicate.to_s] = []
        labels[predicate.to_s] << graph
                    .query(predicate: predicate)
                    .select { |statement| !statement.is_a?(Array) }
                    .map { |statement| statement.object.to_s }
        labels[predicate.to_s].flatten!.compact!
      end
      labels
    end
  end
end