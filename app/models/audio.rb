# frozen_string_literal:true

# Sets the expected attributes and other important values for an audio work
class Audio < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::WorkBehavior

  self.indexer = AudioIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::GenericMetadata

  def update_index
    super
    FetchGraphWorker.perform_async(id, depositor)
  end
end
