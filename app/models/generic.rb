# frozen_string_literal:true

# Sets the expected behaviors of a generic work
class Generic < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::TriplePoweredProperties::WorkBehavior

  before_save :resolve_oembed_errors
  validate :terms_in_controlled_vocabulary

  self.indexer = GenericIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::GenericMetadata

  # If the oembed_url changed all previous errors are invalid
  def resolve_oembed_errors
    errors = OembedError.find_by(document_id: id)
    errors.delete if oembed_url_changed? && !errors.blank?
  end

  def terms_in_controlled_vocabulary
    controlled_properties.each do |terms|
      self.send(terms).each do |term|
        Rails.logger.info(term)
        errors.add(:term, "URI #{term} not in vocabulary") unless term.valid?
      end
    end
  end
end
