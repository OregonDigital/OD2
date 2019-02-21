
module Qa::Authorities
  # Base authority
  class EthnographicTerm < Qa::Authorities::Base
    include WebServiceBase
    include OregonDigital::Authorities::WebServiceRedirect

    included do
      class_attribute :label
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(term)
      [{ 'id' => term.first['@id'].to_s,
         'label' => label.call(term) }]
    end

    def find_term(response, q)
      response.select { |resp| resp['@id'] == q }
    end
  end
end
