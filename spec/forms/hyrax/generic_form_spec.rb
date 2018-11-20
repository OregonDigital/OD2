# Generated via
#  `rails generate hyrax:work Generic`
require 'rails_helper'

RSpec.describe Hyrax::GenericForm do
  let(:new_form) { described_class.new(Generic.new, nil, double('Controller')) }
  let(:user) do
    create(:user)
  end
  let(:ability) { double('Ability') }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
    %i[alternative
  caption_title
  tribal_title
  arranger
  artist
  author
  cartographer
  collector
  composer
  creator_display
  dedicatee
  donor
  designer
  editor
  former_owner
  illustrator
  interviewee
  interviewer
  lyricist
  owner
  patron
  photographer
  print_maker
  recipient
  scribe
  transcriber
  translator
  abstract
  accepted_name_usage
  biographical_information
  canzoniere_poems
  compass_direction
  contents
  cover_description
  coverage
  description_of_manifestation
  form_of_work
  identification_verification_status
  inscription
  layout
  military_highest_rank
  military_occupation
  military_service_location
  mode_of_issuance
  mods_note
  object_orientation
  original_name_usage
  tribal_notes
  source_condition
  specimentype
  temporal
  taxon_class
  cultural_context
  ethnographic_term
  event
  family
  genus
  order
  species
  subject
  military_branch
  phylum_or_division
  sports_team
  state_or_edition
  style_or_period
  lc_subject
  tribal_classes
  tribal_terms
  common_name
  scientific_name_authorship
  higher_classification
  identification_verification_status
  award
  legal_name
  box_name
  box_number
  citation
  current_repository_id
  folder_name
  folder_number
  local_collection_id
  local_collection_name
  location_copyshelf_location
  publisher
  language
  place_of_production
  provenance
  publication_place
  repository
  source
  series_name
  series_number
  art_series
  has_finding_aid
  has_part
  has_version
  isPartOf
  is_version_of
  has_part
  relation
  dcmi_type
  workType
  extent
  format
  material
  measurements
  physical_extent
  technique
  exhibit
  primary_set
  set
  conversion
  copy_location
  date_digitized
  file_size
  institution
  modified
  replaces_url
  submission_date
  box
  gps_latitude
  gps_longitude
  location
  street_address
  ranger_district
  tgn
  water_basin
  award_date
  created
  collected_date
  date issued
  view_date
  acquisition_date
  accession_number
  barcode
  hydrologic_unit_code
  item_locator
  longitude_latitude_identification
  copyright_claimant
  rights
  rights_holder
  license
  use_restrictions
  access_restrictions].each do |t|
      expect(described_class.terms).to include(t)
    end
  end
end
