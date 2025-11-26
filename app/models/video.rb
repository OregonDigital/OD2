# frozen_string_literal:true

# Sets basic behaviors for a video work
class Video < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::WorkBehavior
  # temporarily block EDTF validation
  # include ::OregonDigital::ValidatesEDTFBehavior

  self.indexer = VideoIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::GenericMetadata
  include ::OregonDigital::VideoMetadata
  include ::OregonDigital::ControlledPropertiesBehavior

  private

  # DEFAULT: Set value on default on new work
  def set_defaults
    self.accessibility_feature = ['unknown']
  end
end
