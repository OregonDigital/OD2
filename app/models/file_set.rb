# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  before_save :resolve_oembed_errors

  property :oembed_url, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/oembed'), multiple: false
  property :bulkrax_identifier, predicate: ::RDF::URI.new('http://id.loc.gov/vocabulary/identifiers/local'), multiple: true, basic_searchable: true do |index|
    index.as :stored_searchable
  end

  include ::Hyrax::FileSetBehavior
  include OregonDigital::AccessControls::Visibility
  include OregonDigital::TextExtractedBehavior

  directly_contains :hocr, has_member_relation: ::RDF::Vocab::LDP.hasMemberRelation, class_name: 'Hydra::PCDM::File'

  attr_writer :ocr_content, :bbox_content

  self.indexer = OregonDigital::FileSetIndexer

  def oembed?
    !oembed_url.nil? && !oembed_url.empty?
  end

  def self.characterization_terms
    %i[
      format_label file_size well_formed valid date_created fits_version
      exif_version original_checksum byte_order compression height width color_space
      profile_name profile_version orientation color_map image_producer capture_device
      scanning_software gps_timestamp latitude longitude file_title creator page_count
      language word_count character_count line_count character_set markup_basis markup_language
      paragraph_count table_count graphics_count bit_depth channels data_format frame_rate
      bit_rate duration sample_rate offset aspect_ratio
    ]
  end
  delegate(*characterization_terms, to: :characterization_proxy)

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

  private

  # If the oembed_url changed all previous errors are invalid
  def resolve_oembed_errors
    errors = OembedError.find_by(document_id: id)
    errors.delete if oembed_url_changed? && !errors.blank?
  end
end
