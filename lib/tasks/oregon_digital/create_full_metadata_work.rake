# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create full metadata work for testing'
  task create_full_metadata_work: :environment do
    (0..10).each do
      g = Generic.new
      attributes = build_attributes
      g.attributes = attributes
      g.id = ::Noid::Rails::Service.new.minter.mint
      g.license = ['https://creativecommons.org/licenses/by/4.0/']
      g.language = ['http://id.loc.gov/vocabulary/iso639-2/zun']
      g.resource_type = 'http://purl.org/dc/dcmitype/Collection'
      g.rights_statement = ['http://rightsstatements.org/vocab/InC/1.0/']
      g.save!
    end
  end
end

def build_attributes
  generic_attributes = {}
  attrs.each_pair do |key, value|
    default_value = key.include?('date') || key == 'issued' ?  '1993-12-31' : 'bacon'
    if value.nil?
      generic_attributes[key] = default_value
    elsif value.is_a?(Array) && !value.empty?
      generic_attributes["#{key}_attributes"] = nested_attributes(value.first)
    elsif value.is_a?(Array) && value.empty?
      generic_attributes[key] = [default_value]
    else
      generic_attributes[key] = value
    end
  end
  generic_attributes['title'] = ["Bacon #{Generic.all.count}"]
  generic_attributes
end

def nested_attributes(id)
  { '0' => { 'id' => id, '_destroy' => '' } }
end

# Maybe needs state?
def attrs
  {
    'depositor' => nil,
    'date_uploaded' => Hyrax::TimeService.time_in_utc,
    'date_modified' => nil,
    'proxy_depositor' => nil,
    'on_behalf_of' => nil,
    'arkivo_checksum' => nil,
    'owner' => ['http://id.loc.gov/authorities/names/n86075640'],
    'label' => nil,
    'date_created' => [],
    'description' => [],
    'identifier' => [],
    'alternative' => [],
    'tribal_title' => [],
    'creator_display' => [],
    'former_owner' => [],
    'abstract' => [],
    'accepted_name_usage' => [],
    'biographical_information' => [],
    'compass_direction' => [],
    'cover_description' => [],
    'coverage' => [],
    'description_of_manifestation' => [],
    'designer_inscription' => [],
    'identification_verification_status' => nil,
    'inscription' => [],
    'layout' => [],
    'military_highest_rank' => nil,
    'military_occupation' => [],
    'military_service_location' => [],
    'mode_of_issuance' => [],
    'mods_note' => [],
    'motif' => [],
    'object_orientation' => nil,
    'original_name_usage' => [],
    'tribal_notes' => [],
    'source_condition' => [],
    'specimen_type' => nil,
    'temporal' => [],
    'event' => [],
    'keyword' => [],
    'sports_team' => [],
    'state_or_edition' => [],
    'tribal_classes' => [],
    'tribal_terms' => [],
    'scientific_name_authorship' => [],
    'award' => [],
    'legal_name' => [],
    'box_number' => [],
    'citation' => [],
    'current_repository_id' => [],
    'folder_name' => [],
    'folder_number' => [],
    'local_collection_id' => [],
    'location_copyshelf_location' => [],
    'language' => [],
    'provenance' => [],
    'source' => [],
    'series_name' => [],
    'series_number' => [],
    'art_series' => [],
    'has_finding_aid' => [],
    'has_part' => [],
    'has_version' => [],
    'is_part_of' => [],
    'is_version_of' => [],
    'relation' => [],
    'related_url' => [],
    'workType' => ['http://opaquenamespace.org/ns/workType/AdviceofCharge'],
    'material' => [],
    'measurements' => [],
    'physical_extent' => [],
    'technique' => [],
    'exhibit' => [],
    'conversion' => [],
    'copy_location' => [],
    'replaces_url' => 'http://bacon',
    'rights_note' => [],
    'box' => [],
    'gps_latitude' => nil,
    'gps_longitude' => nil,
    'street_address' => [],
    'award_date' => [],
    'collected_date' => [],
    'date' => [],
    'issued' => [],
    'view_date' => [],
    'acquisition_date' => [],
    'accession_number' => [],
    'barcode' => [],
    'hydrologic_unit_code' => [],
    'item_locator' => [],
    'longitude_latitude_identification' => [],
    'copyright_claimant' => [],
    'rights_holder' => [],
    'use_restrictions' => [],
    'original_filename' => nil,
    'full_size_download_allowed' => 1,
    'access_restrictions' => ['http://opaquenamespace.org/ns/accessRestrictions/OSUrestricted'],
    'arranger' => ['http://id.loc.gov/authorities/names/no2010022998'],
    'artist' => ['http://vocab.getty.edu/ulan/500121373'],
    'author' => ['http://opaquenamespace.org/ns/creator/ClarkeRuthJohnson'],
    'cartographer' => ['http://opaquenamespace.org/ns/creator/ClarkeRuthJohnson'],
    'collector' => ['http://opaquenamespace.org/ns/people/VincentChesterA'],
    'composer' => ['http://id.loc.gov/authorities/names/n85049048'],
    'creator' => ['http://id.loc.gov/authorities/names/n84017617'],
    'contributor' => ['http://id.loc.gov/authorities/names/n84017617'],
    'dedicatee' => ['http://id.loc.gov/authorities/names/n84017617'],
    'donor' => ['http://id.loc.gov/authorities/names/n84017617'],
    'designer' => ['http://id.loc.gov/authorities/names/n84017617'],
    'editor' => ['http://id.loc.gov/authorities/names/n79117033'],
    'illustrator' => ['http://id.loc.gov/authorities/names/n81135212'],
    'interviewee' => ['http://id.loc.gov/authorities/names/no2009199813'],
    'interviewer' => ['http://opaquenamespace.org/ns/creator/UhligElizabeth'],
    'landscape_architect' => ['http://opaquenamespace.org/ns/creator/UhligElizabeth'],
    'lyricist' => ['http://opaquenamespace.org/ns/creator/HealyRobert'],
    'patron' => ['http://opaquenamespace.org/ns/creator/HealyRobert'],
    'photographer' => ['http://opaquenamespace.org/ns/creator/GiffordandPrentiss'],
    'print_maker' => ['http://opaquenamespace.org/ns/creator/SprecherChappellCompanyMusicPrinters'],
    'recipient' => ['http://id.loc.gov/authorities/names/nr98004301'],
    'transcriber' => ['http://opaquenamespace.org/ns/people/RanseenSusanne'],
    'translator' => ['http://opaquenamespace.org/ns/creator/HedgeLaurenC'],
    'location' => ['https://sws.geonames.org/5725846/'],
    'place_of_production' => ['https://sws.geonames.org/4929022/'],
    'publication_place' => ['https://sws.geonames.org/4929022/'],
    'ranger_district' => ['https://sws.geonames.org/5711134/'],
    'water_basin' => ['https://sws.geonames.org/294624/'],
    'cultural_context' => ['http://vocab.getty.edu/aat/300073715'],
    'ethnographic_term' => ['http://id.loc.gov/vocabulary/ethnographicTerms/afset011049'],
    'style_or_period' => ['http://vocab.getty.edu/aat/300021712'],
    'form_of_work' => ['http://id.loc.gov/authorities/subjects/sh85005966'],
    'institution' => ['http://id.loc.gov/authorities/names/n80126183'],
    'local_collection_name' => ['http://opaquenamespace.org/ns/localCollectionName/p_040'],
    'tgn' => ['http://vocab.getty.edu/tgn/7003712'],
    'repository' => ['http://id.loc.gov/authorities/names/n00020491'],
    'publisher' => ['http://id.loc.gov/authorities/names/n80017721'],
    'taxon_class' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=99208'],
    'family' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=117268'],
    'genus' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=154397'],
    'order' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=152741'],
    'species' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=714826'],
    'phylum_or_division' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=69458'],
    'common_name' => ['https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=117268'],
    'military_branch' => ['http://id.loc.gov/authorities/names/n78095328'],
    'subject' => ['http://id.loc.gov/authorities/subjects/sh85076502'],
    'access_control_id' => '45bf2547-f9b2-4fbb-8a41-2a19cfa84802',
    'admin_set_id' => 'admin_set/default'
  }
end
