# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Subject < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Subject
    end

    def parse_authority_response(term, vocabulary)
      resp = super(term[:response], vocabulary)
      resp.first['id'] ||= term[:q]
      resp
    end

    def find_term(response, q)
      { q: q, response: super }
    end

    # WikiData doesn't support a native .jsonld implementation, so we shim in the id here
    # And parse the label as regular JSON
    def json(url)
      json = super
      return json unless controlled_vocabulary.query_to_vocabulary(url) == OregonDigital::ControlledVocabularies::Vocabularies::Wikidata

      json['@id'] = url
      json
    end
  end
end
