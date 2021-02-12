# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  before_save :resolve_oembed_errors

  property :oembed_url, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/oembed'), multiple: false

  include ::Hyrax::FileSetBehavior
  include OregonDigital::AccessControls::Visibility
  attr_writer :ocr_content, :hocr_content, :bbox_content

  self.indexer = OregonDigital::FileSetIndexer

  def oembed?
    !oembed_url.nil? && !oembed_url.empty?
  end

  def ocr_content
    @ocr_content ||= SolrDocument.find(id).to_h.dig('all_text_tsimv')
  rescue Blacklight::Exceptions::RecordNotFound
    nil
  end

  def bbox_content
    @bbox_content ||= SolrDocument.find(id).to_h.dig('all_text_bbox_tsimv')
  rescue Blacklight::Exceptions::RecordNotFound
    nil
  end

  def hocr_content
    @hocr_content ||= SolrDocument.find(id).to_h.dig('hocr_content_tsimv')
  rescue Blacklight::Exceptions::RecordNotFound
    nil
  end

  private

  # If the oembed_url changed all previous errors are invalid
  def resolve_oembed_errors
    errors = OembedError.find_by(document_id: id)
    errors.delete if oembed_url_changed? && !errors.blank?
  end
end
