# frozen_string_literal true
class SolrDocument
  include BlacklightSolrDocument
  include BlacklightGalleryOpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include HyraxSolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(BlacklightDocumentEmail)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(BlacklightDocumentSms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See BlacklightDocumentSemanticFields#field_semantics
  # and BlacklightDocumentSemanticFields#to_semantic_values
  # Recommendation Use field names from Dublin Core
  use_extension(BlacklightDocumentDublinCore)

  # Do content negotiation for AF models.

  use_extension( HydraContentNegotiation )

  def self.solrized_methods(property_names)
    property_names.each do |property_name|
      define_method property_name.to_sym do
        values = self[Solrizer.solr_name(property_name)]
        if values.respond_to?(each)
          values.reject(&blank?)
        else
          values
        end
      end
    end
  end

  ### Image Metadata ###
  def colour_content
    self[Solrizer.solr_name('colour_content')]
  end

  def color_space
    self[Solrizer.solr_name('color_space')]
  end

  def height
    self[Solrizer.solr_name('height')]
  end

  def orientation
    self[Solrizer.solr_name('orientation')]
  end

  def photograph_orientation
    self[Solrizer.solr_name('photograph_orientation')]
  end

  def resolution
    self[Solrizer.solr_name('resolution')]
  end

  def view
    self[Solrizer.solr_name('view')]
  end

  def width
    self[Solrizer.solr_name('width')]
  end

  ### Document Metadata ###
  def contained_in_journal
    self[Solrizer.solr_name('contained_in_journal')]
  end

  def first_line
    self[Solrizer.solr_name('first_line')]
  end

  def first_line_chorus
    self[Solrizer.solr_name('first_line_chorus')]
  end

  def has_number
    self[Solrizer.solr_name('has_number')]
  end

  def host_item
    self[Solrizer.solr_name('host_item')]
  end

  def instrumentation
    self[Solrizer.solr_name('instrumentation')]
  end

  def is_volume
    self[Solrizer.solr_name('is_volume')]
  end

  def larger_work
    self[Solrizer.solr_name('larger_work')]
  end

  def number_of_pages
    self[Solrizer.solr_name('number_of_pages')]
  end

  def table_of_contents
    self[Solrizer.solr_name('table_of_contents')]
  end

  ### Generic Metadata ###
  solrized_methods %w[alternative
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
  is_part_of
  is_version_of
  has_part
  relation
  dcmi_type
  work_type
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
  access_restriction]

  def oembed_url
    self[Solrizer.solr_name('oembed_url')]
  end
end
