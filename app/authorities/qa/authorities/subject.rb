# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Subject < BaseAuthority
    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::Subject
    end

    def parse_authority_response(term, vocabulary)
      [{ 'id' => term[:q],
         'label' => label.call(term[:response], vocabulary) }]
    end

    def search(q)
      vocabulary = controlled_vocabulary.query_to_vocabulary(q)
      if vocabulary == OregonDigital::ControlledVocabularies::Vocabularies::Ubio
        parse_authority_response(find_term(xml(vocabulary.as_query(q)), q), vocabulary)
      else
        super
      end
    end

    def xml(url)
      Nokogiri::XML(Faraday.get(url.delete('\\')).body)
    end

    def find_term(response, q)
      { q: q, response: response }
    end
  end
end
