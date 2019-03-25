# frozen_string_literal:true

require 'triplestore_adapter'

module OregonDigital
  # Configuration to allow connection to triplestore
  class Triplestore
    ##
    # Query the graph found at the supplied uri
    #
    # @param uri [String] the uri for the graph
    # @return [RDF::Graph] the graph
    def self.fetch(uri, user)
      return if uri.blank?

      begin
        @triplestore ||= TriplestoreAdapter::Triplestore.new(triplestore_client)
        @triplestore.fetch(uri, from_remote: true)
      rescue TriplestoreAdapter::TriplestoreException => e
        # TODO: Prevent double and duplicate job submission/emails
        # Parse HTTP status code and enqueue if in the 4xx or 5xx range
        error = e.message.match(/\(([0-9]*)\)$/).captures.first
        if error.present? && error.to_i >= 400
          LinkedDataWorker.perform_in(15.minutes, uri, user)

          # Email user about failure
          Hyrax.config.callback.run(:ld_fetch_error, user, uri)
          nil
        else
          raise e
        end
      end
    end

    def self.triplestore_client
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
