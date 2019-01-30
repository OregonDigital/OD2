module Qa::Authorities
  class Format < Qa::Authorities::Base
    include WebServiceBase

    class_attribute :label

    self.label = lambda do |item|
      [item.first["http://www.w3.org/2000/01/rdf-schema#label"].first["@value"]].compact.join(', ')
    end

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      URI.escape(q)
    end

    private

      # Reformats the data received from the service
      def parse_authority_response(response)
          [{ 'id' => "#{response.first["@id"]}",
            'label' => label.call(response) }]
      end
  end
end
