# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Ubio
      def self.expression
        %r{.+ubio.org\/authority\/metadata.*}
      end

      def self.label(data)
        data.at_xpath('/rdf:RDF/rdf:Description/dc:title/text()')
      end

      def self.as_query(q)
        q
      end
    end
  end
end
