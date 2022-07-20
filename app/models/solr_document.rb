# frozen_string_literal: true

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
  use_extension(Hydra::ContentNegotiation)

  def self.solrized_methods(property_names)
    property_names.each do |property_name|
      attribute property_name, Solr::Array, "#{property_name}_tesim"
    end
  end

  # Turn document type into FontAwesome icon class
  # See app\views\catalog\_index_list_type_icon.html.erb
  def type_to_fa_class(type)
    fa_classes = {
      'complex object': 'cubes',
      'dataset': 'database',
      'image': 'picture-o',
      'moving image': 'video-camera',
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
    config = ::CatalogController.new
    repository = config.repository
    search_builder = OregonDigital::ParentsSearchBuilder.new(id: self['id'])
    @parents ||= repository.search(search_builder).docs
  end

  def parents?
    !parents.empty?
  end

  # Find and return child works (excluding FileSets)
  def children
    @children ||= member_ids.map do |member_id|
      document = SolrDocument.find(member_id)
      document['has_model_ssim'].first == 'FileSet' ? nil : document
    end.compact
  end

  def children?
    !children.empty?
  end

  # Find and return file sets
  def file_sets
    @file_sets ||= member_ids.map do |member_id|
      document = SolrDocument.find(member_id)
      document['has_model_ssim'].first == 'FileSet' ? document : nil
    end.compact
  end

  def file_sets?
    !file_sets.empty?
  end

  field_semantics.merge!(
    contributor:  ['contributor_tesim', 'editor_tesim', 'contributor_advisor_tesim', 'contributor_committeemember_tesim', 'oai_academic_affiliation_label'],
    coverage:     ['based_near_label_tesim', 'conferenceLocation_tesim'],
    creator:      'creator_tesim',
    date:         'date_created_tesim',
    description:  ['description_tesim', 'abstract_tesim'],
    format:       ['file_extent_tesim', 'file_format_tesim'],
    identifier:   'oai_identifier',
    language:     'language_label_tesim',
    publisher:    'publisher_tesim',
    relation:     'oai_nested_related_items_label',
    rights:       'oai_rights',
    source:       ['source_tesim', 'isBasedOnUrl_tesim'],
    subject:      ['subject_tesim', 'keyword_tesim'],
    title:        'title_tesim',
    type:         'resource_type_tesim'
  )


  # Override SolrDocument hash access for certain virtual fields
  def [](key)
    return send(key) if ['oai_academic_affiliation_label', 'oai_rights', 'oai_identifier', 'oai_nested_related_items_label'].include?(key)
    super
  end

  def sets
    fetch('has_model', []).map { |m| BlacklightOaiProvider::Set.new("has_model_ssim:#{m}") }
  end

  def oai_nested_related_items_label
    related_items = []
    nested_related_items_label.each do |r|
      related_items << r["label"] + ': ' + r["uri"]
    end
    related_items
  end

  def oai_academic_affiliation_label
    aa_labels = []
    academic_affiliation_label.each do |a|
      aa_labels << a["label"]
    end
    aa_labels
  end

  # Only return License if present, otherwise Rights
  def oai_rights
    license_label ? license_label : rights_statement_label
  end

  def oai_identifier
    Rails.application.routes.url_helpers.url_for(:only_path => false, :action => 'show', :host => CatalogController.blacklight_config.oai[:provider][:repository_url], :controller => 'hyrax/' + self["has_model_ssim"].first.to_s.underscore.pluralize, id: self.id)
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
