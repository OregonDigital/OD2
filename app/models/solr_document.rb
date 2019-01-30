# frozen_string_literal: true

# Sets behaviors for the solr document
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
  include Hyrax::SolrDocumentBehavior

  SolrDocument.use_extension(Blacklight::Document::Email)
  SolrDocument.use_extension(Blacklight::Document::Sms)
  use_extension(Blacklight::Document::DublinCore)
  use_extension(Hydra::ContentNegotiation)

  def self.solrized_methods(property_names, model)
    property_names.each do |property_name|
      define_method property_name.to_sym do
        values = self[Solrizer.solr_name(property_name.to_s, :stored_searchable)]
        valid_solr_doc_values(values, model, property_name)
      end
    end
  end

  private

  def valid_solr_doc_values(values, model, property_name)
    if values.respond_to?(:each)
      values.reject(&:blank?)
    elsif values.blank?
      Hyrax::FormMetadataService.multiple?(model, property_name) ? [] : ''
    else
      values
    end
  end

  solrized_methods OregonDigital::GenericMetadata::PROPERTIES, Generic
  solrized_methods OregonDigital::DocumentMetadata::PROPERTIES, Document
  solrized_methods OregonDigital::ImageMetadata::PROPERTIES, Image
  solrized_methods OregonDigital::VideoMetadata::PROPERTIES, Video
end
