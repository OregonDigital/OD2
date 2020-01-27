# frozen_string_literal: true

module OregonDigital
  # Translate feature class
  class FeatureClassUriToLabel
    def uri_to_label(uri)
      { 'https://www.geonames.org/ontology#A' => 'Administrative Boundary',
        'https://www.geonames.org/ontology#H' => 'Hydrographic',
        'https://www.geonames.org/ontology#L' => 'Area',
        'https://www.geonames.org/ontology#P' => 'Populated Place',
        'https://www.geonames.org/ontology#R' => 'Road / Railroad',
        'https://www.geonames.org/ontology#S' => 'Spot',
        'https://www.geonames.org/ontology#T' => 'Hypsographic',
        'https://www.geonames.org/ontology#U' => 'Undersea',
        'https://www.geonames.org/ontology#V' => 'Vegetation' }[uri]
    end
  end
end
