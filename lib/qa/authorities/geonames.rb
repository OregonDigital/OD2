# frozen_string_literal: true

module Qa::Authorities
  # Geonames authority
  class Geonames < Base
    include WebServiceBase

    class_attribute :username, :label

    self.label = lambda do |item, translated_fcl|
      [item['name'], item['adminName1'], item['countryName'], "(#{translated_fcl})"].compact.join(', ')
    end

    def search(q)
      unless username
        Rails.logger.error 'Questioning Authority tried to call geonames, but no username was set'
        return []
      end
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      query = URI.escape(untaint(q))
      "http://api.geonames.org/searchJSON?q=#{query}&username=#{username}&maxRows=10"
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://www.geonames.org/getJSON?geonameId=#{id}&username=#{username}"
    end

    private

      # Reformats the data received from the service
      def parse_authority_response(response)
        response['geonames'].map do |result|
          # Note: the trailing slash is meaningful.
          { 'id' => "http://sws.geonames.org/#{result['geonameId']}/",
            'label' => label.call(result, translate_fcl(result['fcl'])) }
        end
      end

      def translate_fcl(fcl)
        { 'A' => 'Administrative Boundary',
          'H' => 'Hydrographic',
          'L' => 'Area',
          'P' => 'Populated Place',
          'R' => 'Road / Railroad',
          'S' => 'Spot',
          'T' => 'Hypsographic',
          'U' => 'Undersea',
          'V' => 'Vegetation'
        }[fcl]
      end
  end
end