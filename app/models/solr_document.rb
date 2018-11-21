# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

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
  def oembed_url
    self[Solrizer.solr_name('oembed_url')]
  end
end
