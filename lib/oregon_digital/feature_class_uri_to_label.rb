# frozen_string_literal: true

module OregonDigital
  # Translate feature class
  class FeatureClassUriToLabel
    def uri_to_label(uri)
      { 'http://www.geonames.org/ontology#A' => 'Administrative Boundary',
        'http://www.geonames.org/ontology#H' => 'Hydrographic',
        'http://www.geonames.org/ontology#L' => 'Area',
        'http://www.geonames.org/ontology#P' => 'Populated Place',
       'http://www.geonames.org/ontology#R' => 'Road / Railroad',
       'http://www.geonames.org/ontology#S' => 'Spot',
       'http://www.geonames.org/ontology#T' => 'Hypsographic',
       'http://www.geonames.org/ontology#U' => 'Undersea',
       'http://www.geonames.org/ontology#V' => 'Vegetation'
      }[uri]
    end
  end
end