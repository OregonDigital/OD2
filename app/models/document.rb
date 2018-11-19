# Generated via
#  `rails generate hyrax:work Document`
class Document < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # include OD2::GenericMetadata
  include OD2::DocumentMetadata

  self.indexer = DocumentIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
  include ::OregonDigital::TriplePoweredProperties::WorkBehavior
end
