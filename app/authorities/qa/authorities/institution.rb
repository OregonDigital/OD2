# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Institution < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Institution
    end

    private

    def find_term(response, q)
      return super unless controlled_vocabulary.query_to_vocabulary(q) == OregonDigital::ControlledVocabularies::Vocabularies::Dbpedia
      response.select! { |_key, term| term.key?('http://www.w3.org/2000/01/rdf-schema#label') }
      response['@id'] = q
      [response]
    end
  end
end
