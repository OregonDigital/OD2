# frozen_string_literal: true

module Qa::Authorities
  # EthnographicTerm QA Object
  class Repository < BaseAuthority
    self.label = lambda do |item|
      [find_label(item)].compact.join(', ')
    end

    def search(q)
      if OregonDigital::ControlledVocabularies::Repository.in_vocab?(q)
        parse_authority_response(find_term(json(q + '.jsonld'), q))
      else
        []
      end
    end

    def self.find_label(item)
      label = item.first['http://www.w3.org/2000/01/rdf-schema#label'] 
      label.blank? ? item.first["http://www.w3.org/2004/02/skos/core#prefLabel"].first['@value'] : label
    end

    def find_term(response, q)
      response.select { |resp| resp['@id'] == q }
    end
  end
end