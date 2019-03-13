# frozen_string_literal: true

module Qa::Authorities
  # Repository QA Object
  class Repository < BaseAuthority
    self.label = lambda do |data, vocabulary|
      [vocabulary.label(data)].compact.join(', ')
    end

    def search(q)
      vocabulary = OregonDigital::ControlledVocabularies::Repository.query_to_vocabulary(q)
      if vocabulary.present?
        parse_authority_response(find_term(json(vocabulary.as_query(q)), q), vocabulary)
      else
        []
      end
    end

    def find_term(response, q)
      selected_id = response.select { |resp| resp['@id'] == q }
      selected_id.blank? ? [response] : selected_id
    end
  end
end
