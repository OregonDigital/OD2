# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Creator < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Creator
    end

    # WikiData doesn't support a native .jsonld implementation, so we convert RDF to JSONLD
    def json(url)
      return super unless controlled_vocabulary.query_to_vocabulary(url) == OregonDigital::ControlledVocabularies::Vocabularies::WdEntity
      r = RDF::Graph.load(url + '.rdf').dump(:jsonld)
      JSON.parse(r)
    end
  end
end
