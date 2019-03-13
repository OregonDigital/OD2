# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Generic object for storing labels and uris
    class Resource < ActiveTriples::Resource
      # Override ActiveTriples::Resource to enforce vocabulary membership
      #
      # @see ActiveTriples::Resource
      def initialize(*args, &block)
        super
        # If rdf_subject wasn't set, we're done
        return if node?

        # Reset rdf_subject and set it through the proper method
        resource_uri = @rdf_subject
        @rdf_subject = nil
        set_subject!(resource_uri)
      end

      ##
      # Override fetch to use the triplestore caching mechanism to get the graph,
      # store it locally, and fetch it from the cache, then assign it to the resources
      # "persistence_strategy.graph" which makes other methods like "rdf_label" make
      # use of the provided graph.
      def fetch(*_args, &_block)
        persistence_strategy.graph = triplestore_fetch
      end

      # Override ActiveTriples::Resource.set_subject! to throw exception if term isn't in vocab
      def set_subject!(uri_or_str)
        raise ControlledVocabularyError, "Term not in controlled vocabulary: #{uri_or_str}" unless
          uri_in_vocab?(uri_or_str.to_s)
        super
      end

      # Return a tuple of url & label
      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label_uri_same?
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      # Sanity check for valid rdf_subject. Subject should never be blank but in the event,
      # it should return an empty graph.
      def triplestore_fetch
        URI.parse(rdf_subject).is_a?(URI::HTTP) ? triplestore.fetch(rdf_subject) : RDF::Graph.new
      end

      def triplestore
        OregonDigital::Triplestore
      end

      # Return Vocabulary class with matching URI regex
      def self.query_to_vocabulary(uri)
        return nil if all_endpoints.blank?
        all_endpoints.each do |endpoint|
          return endpoint if endpoint.expression.match?(uri)
        end
        nil
      end

      # Return T/F if a URI is in the vocab
      def self.in_vocab?(uri)
        query_to_vocabulary(uri).present?
      end

      private

      def rdf_label_uri_same?
        rdf_label.first.to_s == rdf_subject.to_s
      end

      def uri_in_vocab?(uri)
        self.class.respond_to?(:in_vocab?) && self.class.in_vocab?(uri)
      end
    end
    class ControlledVocabularyError < StandardError; end
  end
end
