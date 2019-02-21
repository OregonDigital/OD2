# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Media Type object for storing labels and uris
    class MediaType < Resource
      # Return T/F if a URI is in the vocab
      def self.in_vocab?(uri)
        valid_uri = %r{^http[s]?:\/\/w3id.org\/spar\/mediatype\/.*/.*}
        valid_uri.match?(uri)
      end

      def fetch(*_args, &_block)
        @graph = triplestore.triplestore_client.get_statements(subject: rdf_subject.to_s)
        if @graph.statements.blank?
          @graph = RDF::Graph.load(sanitize_subject_uri(rdf_subject))
          triplestore.triplestore_client.provider.insert(@graph.statements)
        end
        persistence_strategy.graph = @graph
      end

      private

      def sanitize_subject_uri(subject)
        if OregonDigital::ControlledVocabularies::MediaType.in_vocab?(subject.to_s) 
          uri = URI.parse(subject.to_s)
          return "#{uri.scheme}://#{uri.hostname + uri.request_uri.split('.')[0]}.rdf"
        end
      end
    end
  end
end
