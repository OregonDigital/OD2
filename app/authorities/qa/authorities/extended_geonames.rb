# frozen_string_literal: true

module Qa::Authorities
  # Geonames authority
  class ExtendedGeonames < Qa::Authorities::Geonames
    include WebServiceBase

    self.label = lambda do |item, translated_fcl|
      [item['name'], item['adminName1'], item['countryName'], "(#{translated_fcl})"].compact.join(', ')
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