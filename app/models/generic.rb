# Generated via
#  `rails generate hyrax:work Generic`
class Generic < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::TriplePoweredProperties::WorkBehavior

  self.indexer = GenericIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # oEmbed property
  property :oembed_url, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
