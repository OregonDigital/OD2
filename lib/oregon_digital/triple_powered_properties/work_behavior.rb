# frozen_string_literal:true

module OregonDigital::TriplePoweredProperties
  # Allows a work to be triple powered
  module WorkBehavior
    extend ActiveSupport::Concern

    included do
      # store the triple powered property labels in SOLR
      self.indexer = OregonDigital::TriplePoweredProperties::WorkIndexer

      # server side validation for triple powered property values being valid urls
      validates_with OregonDigital::TriplePoweredProperties::HasUrlValidator

      class_attribute :triple_powered_properties

      # fetch the graphs and store them in the triple store cache before saving the work
      before_save :fetch_graphs

      def triple_powered_properties
        [:based_near]
      end
    end

    ##
    # Queries the labels for each graph associated with the triple powered property
    #
    # @param key [Symbol] the property uri with associated graphs
    # @return [Hash<String,Array<String>>] a hash keyed on the URI with its labels as the value
    def uri_labels(property)
      labels = {}

      return labels if uri_graphs.nil?
      return labels if uri_graphs[property].nil?

      uri_graphs[property].each do |h|
        result = h[:result]
        uri = h[:uri]
        labels[uri] = []
        if result.is_a?(String)
          labels[uri] << result
        else
          labels[uri] << OregonDigital::TriplePoweredProperties::Triplestore.predicate_labels(result).values.flatten.compact
        end
      end
      labels
    end

    def uri_graphs
      @uri_graphs ||= build_uri_graphs
    end

    private

    ##
    # Connect to the triplestore backend, and fetch the graphs
    def fetch_graphs
      uri_graphs
    end

    ##
    # Build a hash, keyed on the property symbol, of graphs related to each triple powered property
    def build_uri_graphs
      graphs = {}
      # iterate through each of the properties having RDF URIs and fetch the graphs from the triplestore
      triple_powered_properties.each do |property|
        graphs[property] = fetch(property)
      end
      graphs
    end

    ##
    # Fetch the graphs for each URI value set on the property
    # @param [Symbol] the property which is triple powered
    # @return [Array<String>] the array of graphs for each URI value in the property
    #                         OR the original URI if fetching the graphs fails (invalid URI, for instance)
    def fetch(property)
      # iterate through each of the uri's stored in the property of this model
      self[property].map do |uri|
        # Fetch the graph from the triplestore, or return the uri
        graph = OregonDigital::TriplePoweredProperties::Triplestore.fetch(uri)
        { uri: uri, result: graph }
      rescue TriplestoreAdapter::TriplestoreException
        { uri: uri, result: uri }
      end
    end
  end
end
