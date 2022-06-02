# frozen_string_literal:true

# Sets the expected behaviors of a generic work
class Generic < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::WorkBehavior
  # temporarily block EDTF validation
  # include ::OregonDigital::ValidatesEDTFBehavior

  self.indexer = GenericIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::GenericMetadata
  include ::OregonDigital::ControlledPropertiesBehavior
end
