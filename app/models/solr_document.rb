# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# Sets behaviors for the solr document
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
  include Hyrax::SolrDocumentBehavior
  include BlacklightOaiProvider::SolrDocument
  include OregonDigital::SolrDocumentBehavior

  SolrDocument.use_extension(Blacklight::Document::Email)
  SolrDocument.use_extension(Blacklight::Document::Sms)
  use_extension(Blacklight::Document::DublinCore)
  SolrDocument.use_extension(OregonDigital::QualifiedDublinCore)
  use_extension(Hydra::ContentNegotiation)

  delegate :bbox, :extracted_text, :hocr, to: :resource

  def self.solrized_methods(property_names)
    property_names.each do |property_name|
      attribute property_name, Solr::Array, "#{property_name}_tesim"
    end
  end

  # Add support for querying for multiple ids
  def self.find(ids)
    return super(ids) unless ids.is_a? Array
    return [] if ids.blank?

    docs = repository.find(ids)
    docs.documents
  end

  # Turn document type into FontAwesome icon class
  # See app\views\catalog\_index_list_type_icon.html.erb
  def type_to_fa_class(type)
    fa_classes = {
      'complex object': 'cubes',
      'dataset': 'database',
      'image': 'picture-o',
      'video': 'video-camera',
      'physical object': 'archive',
      'audio': 'music',
      'text': 'file-text'
    }.with_indifferent_access
    fa_classes[type.downcase] || 'cube'
  end

  # Turn rights statement into FontAwesome icon class
  # See app\views\catalog\_index_list_default.html.erb
  # rubocop:disable Metrics/MethodLength
  def rights_statement_to_fa_class(rights_statement)
    fa_classes = {
      'http://rightsstatements.org/vocab/InC/1.0/': 'far fa-copyright',
      'http://rightsstatements.org/vocab/InC-OW-EU/1.0/': 'far fa-copyright',
      'http://rightsstatements.org/vocab/InC-EDU/1.0/': 'far fa-copyright',
      'http://rightsstatements.org/vocab/InC-NC/1.0/': 'far fa-copyright',
      'http://rightsstatements.org/vocab/InC-RUU/1.0/': 'far fa-copyright',
      'http://rightsstatements.org/vocab/NoC-CR/1.0/': 'fab fa-creative-commons-pd',
      'http://rightsstatements.org/vocab/NoC-NC/1.0/': 'fab fa-creative-commons-pd',
      'http://rightsstatements.org/vocab/NoC-OKLR/1.0/': 'fab fa-creative-commons-pd',
      'http://rightsstatements.org/vocab/NoC-US/1.0/': 'fab fa-creative-commons-pd',
      'http://rightsstatements.org/vocab/CNE/1.0/': 'far fa-question-circle',
      'http://rightsstatements.org/vocab/UND/1.0/': 'far fa-question-circle',
      'http://rightsstatements.org/vocab/NKC/1.0/': 'far fa-question-circle'
    }.with_indifferent_access
    fa_classes[rights_statement] || 'far fa-question-circle'
  end
  # rubocop:enable Metrics/MethodLength

  # Find and return parent works
  def parents
    @parents ||= Hyrax::SolrService.get("{!field f=member_ids_ssim}#{id}")['response']['docs'].map do |doc|
      SolrDocument.new(doc)
    end
  end

  def parents?
    !parents.empty?
  end

  # Find and return child works (excluding FileSets)
  def children
    return @children unless @children.nil?

    sort_members
    @children
  end

  def sort_members
    @children = []
    @file_sets = []
    member_ids.each_slice(OD2::Application.config.max_members_query) do |chunk|
      process_chunk(chunk)
    end
  end

  def process_chunk(chunk)
    SolrDocument.find(chunk.reject(&:blank?)).map do |document|
      if document['has_model_ssim'].first.include?('FileSet')
        @file_sets << document
      else
        @children << document
      end
    end
  end

  def children?
    !children.empty?
  end

  # Find and return file sets
  def file_sets
    return @file_sets unless @file_sets.nil?

    sort_members
    @file_sets
  end

  def file_sets?
    !file_sets.empty?
  end

  field_semantics.merge!(
    title: %w[alternative_tesim tribal_title_tesim title_tesim],
    creator: %w[creator_label_tesim],
    contributor: %w[photographer_label_tesim applicant_label_tesim arranger_label_tesim artist_label_tesim author_label_tesim cartographer_label_tesim collector_label_tesim composer_label_tesim contributor_label_tesim designer_label_tesim donor_label_tesim editor_label_tesim illustrator_label_tesim interviewee_label_tesim interviewer_label_tesim landscape_architect_label_tesim lyricist_label_tesim owner_label_tesim patron_label_tesim print_maker_label_tesim recipient_label_tesim transcriber_label_tesim translator_label_tesim],
    description: %w[description_tesim abstract_tesim cover_description_tesim description_of_manifestation_tesim inscription_tesim view_tesim cultural_context_label_tesim style_or_period_label_tesim award_date_tesim provenance_tesim],
    subject: %w[subject_label_tesim award_tesim ethnographic_term_label_tesim event_tesim keyword_tesim legal_name_tesim military_branch_label_tesim sports_team_tesim tribal_classes_tesim tribal_terms_tesim phylum_or_division_label_tesim taxon_class_label_tesim order_label_tesim family_label_tesim genus_label_tesim species_label_tesim common_name_label_tesim],
    coverage: %w[coverage_tesim temporal_tesim location_label_tesim box_tesim gps_latitude_tesim gps_longitude_tesim ranger_district_label_tesim street_address_tesim tgn_label_tesim water_basin_label_tesim plss_tesim],
    date: %w[date_tesim created_tesim issued_tesim view_date_tesim],
    rights: %w[license_label_tesim rights_holder_tesim rights_note_tesim rights_statement_label_tesim],
    publisher: %w[repository_label_tesim publisher_label_tesim],
    language: %w[language_label_tesim],
    source: %w[source_tesim],
    relation: %w[local_collection_name_label_tesim citation_tesim art_series_tesim has_finding_aid_tesim has_part_tesim has_version_tesim isPartOf_tesim is_version_of_tesim larger_work_tesim relation_tesim collection_tesim],
    type: %w[media_tesim],
    format: %w[measurements_tesim physical_extent_tesim format_label_tesim]
  )

  def sets
    fetch('has_model', []).map { |m| BlacklightOaiProvider::Set.new("has_model_ssim:#{m}") }
  end

  def hocr_text
    '' unless file_set?
    @hocr_text ||= resource.hocr_text.presence
  end

  def all_text
    '' unless file_set?
    @all_text ||= resource.extracted_text&.content.presence
  end

  def non_user_collections
    self['non_user_collections_ssim']
  end

  def oai_collections
    self['oai_collections_ssim']
  end

  # METHOD: Fetch the ssim for 'label$uri'
  def label_uri_helpers(attribute_name)
    OregonDigital::LabelParserService.parse_label_uris(self["#{attribute_name}_parsable_label_ssim"])
  end

  def resource
    @resource ||= Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id, use_valkyrie: false)
  end

  solrized_methods Generic.generic_properties
  solrized_methods Document.document_properties
  solrized_methods Image.image_properties
  solrized_methods Video.video_properties
  solrized_methods Generic.controlled_properties
  solrized_methods Generic.controlled_property_labels
  solrized_methods FileSet.characterization_terms
  solrized_methods %w[resource_type_label language_label rights_statement_label oembed_url]
end
# rubocop:enable Metrics/ClassLength
