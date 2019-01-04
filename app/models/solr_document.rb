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

  def self.solrized_methods(property_names)
    property_names.each do |property_name|
      define_method property_name.to_sym do
        values = self[Solrizer.solr_name(property_name.to_s, :stored_searchable)]
        if values.respond_to?(:each)
          values.reject(&:blank?)
        else
          values
        end
      end
    end
  end

  solrized_methods OregonDigital::GenericMetadata::PROPERTIES
  solrized_methods OregonDigital::DocumentMetadata::PROPERTIES
  solrized_methods OregonDigital::ImageMetadata::PROPERTIES
  solrized_methods OregonDigital::VideoMetadata::PROPERTIES
end
