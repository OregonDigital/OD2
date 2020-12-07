# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  before_save :resolve_oembed_errors

  property :oembed_url, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/oembed'), multiple: false

  include ::Hyrax::FileSetBehavior
  include OregonDigital::AccessControls::Visibility
  attr_accessor :ocr_content, :hocr_content

  self.indexer = OregonDigital::FileSetIndexer

  def oembed?
    !oembed_url.nil? && !oembed_url.empty?
  end

  private

  # If the oembed_url changed all previous errors are invalid
  def resolve_oembed_errors
    errors = OembedError.find_by(document_id: id)
    errors.delete if oembed_url_changed? && !errors.blank?
  end
end
