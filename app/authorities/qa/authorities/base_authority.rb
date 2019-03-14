# frozen_string_literal: true

module Qa::Authorities
  # Base authority
  class BaseAuthority < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    class_attribute :label

    self.label = lambda do |data, vocabulary|
      [vocabulary.label(data)].compact.join(', ')
    end

    def search(q)
      vocabulary = controlled_vocabulary.query_to_vocabulary(q)
      if vocabulary.present?
        parse_authority_response(find_term(json(vocabulary.as_query(q)), q), vocabulary)
      else
        []
      end
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(term, vocabulary)
      [{ 'id' => term.first['@id'].to_s,
         'label' => label.call(term, vocabulary) }]
    end

    def find_term(response, q)
      selected_id = response.select { |resp| resp['@id'] == q }
      selected_id.blank? ? [response] : selected_id
    end
  end
end
