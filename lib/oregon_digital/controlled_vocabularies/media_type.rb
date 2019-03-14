# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Media Type object for storing labels and uris
    class MediaType < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::SparMediaType
        ]
      end

      def fetch(*_args, &_block)
        graph = triplestore_graph
        persistence_strategy.graph = graph.statements.blank? ? set_graph_and_cache : graph
      end

      private

      def triplestore_graph
        triplestore.triplestore_client.get_statements(subject: rdf_subject.to_s)
      end

      def set_graph_and_cache
        graph = RDF::Graph.load(sanitize_subject_uri(rdf_subject))
        triplestore.triplestore_client.provider.insert(graph)
        graph
      end

      def sanitize_subject_uri(subject)
        parse_subject_uri if OregonDigital::ControlledVocabularies::MediaType.in_vocab?(subject.to_s)
      end

      def parse_subject_uri
        uri = URI.parse(rdf_subject.to_s)
        "#{uri.scheme}://#{uri.hostname + uri.request_uri.split('.')[0]}.rdf"
      end
    end
  end
end
