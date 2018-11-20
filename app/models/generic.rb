# Generated via
#  `rails generate hyrax:work Generic`
class Generic < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::TriplePoweredProperties::WorkBehavior
  include OregonDigital::GenericMetadata
  include ::Hyrax::BasicMetadata

  self.indexer = GenericIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  def set_defaults
  end
end
