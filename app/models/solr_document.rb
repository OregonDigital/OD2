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

  def oembed_url
    self[Solrizer.solr_name('oembed_url')]
  end

  def height
    self[Solrizer.solr_name('height')]
  end

  def width
    self[Solrizer.solr_name('width')]
  end
end
