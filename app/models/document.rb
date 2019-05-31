# frozen_string_literal:true

# Sets the expected behaviors and validations for a document
class Document < Generic
  include ::Hyrax::WorkBehavior
  self.indexer = DocumentIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::DocumentMetadata
  include ::OregonDigital::GenericMetadata
end
