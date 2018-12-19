# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
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
  use_extension(Hydra::ContentNegotiation)

  def self.solrized_methods(property_names)
    property_names.each do |property_name|
      define_method property_name.to_sym do
        values = self[Solrizer.solr_name(property_name.to_s, :stored_searchable)]
        if values.respond_to?(:each)
          values.reject(&:blank?)
        else
          values
        end
        values
      end
    end
  end

  solrized_methods OregonDigital::GenericMetadata::PROPERTIES
  solrized_methods OregonDigital::DocumentMetadata::PROPERTIES
  solrized_methods OregonDigital::ImageMetadata::PROPERTIES
  solrized_methods OregonDigital::VideoMetadata::PROPERTIES
end
