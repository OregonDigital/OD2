# frozen_string_literal: true

module Qa::Authorities
  # Geonames authority
  class ExtendedGeonames < Qa::Authorities::Geonames
    include WebServiceBase
    class_attribute :ons_label

    self.ons_label = lambda do |data, vocabulary|
      [vocabulary.label(data)].compact.join(', ')
    end
    self.label = lambda do |item, translated_fcl|
      [item['name'], item['adminName1'], item['countryName'], "(#{translated_fcl})"].compact.join(', ')
    end

    def search(q)
      vocabulary = controlled_vocabulary.query_to_vocabulary(q)
      if vocabulary.present?
        parse_ons_authority_response(find_ons_term(json(vocabulary.as_query(q)), q), vocabulary)
      else
        parse_authority_response(json(build_query_url(q)))
      end
    end

    def controlled_vocabulary
      OregonDigital::ControlledVocabularies::ExtendedLocation
    end

    private

    def find_ons_term(response, q)
      uri = URI.parse(q)
      id = [uri.hostname, uri.path].join
      selected_id = response.select { |resp| resp['@id'].to_s.match? id }
      selected_id.blank? ? Array.wrap(response) : selected_id
    end

    # Reformats the data received from the service
    def parse_authority_response(response)
      response['geonames'].map do |result|
        # Note: the trailing slash is meaningful.
        { 'id' => "https://sws.geonames.org/#{result['geonameId']}/",
          'label' => label.call(result, translate_fcl(result['fcl'])) }
      end
    end

    # Reformats the data received from the service
    def parse_ons_authority_response(term, vocabulary)
      [{ 'id' => term.first['@id'].to_s,
         'label' => ons_label.call(term, vocabulary) }]
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
        'V' => 'Vegetation' }[fcl]
    end
  end
end
