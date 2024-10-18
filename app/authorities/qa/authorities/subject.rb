# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Subject < BaseAuthority
    include GettyAatParsingBehavior

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Subject
    end

    # MODIFY: Override the search to handle the case of BNE Authority File
    def search(q)
      vocabulary = controlled_vocabulary.query_to_vocabulary(q)
      if vocabulary.present?
        if q.to_s.include?('datos.bne.es')
          parse_authority_response(find_term(json(vocabulary.as_query(q)), q), vocabulary, true)
        else
          parse_authority_response(find_term(json(vocabulary.as_query(q)), q), vocabulary)
        end
      else
        []
      end
    end

    # MODIFY: Also modify the parse response due to special case of BNE
    def parse_authority_response(term, vocabulary, bne = false)
      resp = if bne
               [{ 'id' => term[:response].first['@graph'].first['@id'].to_s,
                  'label' => label.call(term[:response], vocabulary) }]
             else
               super(term[:response], vocabulary)
             end

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
