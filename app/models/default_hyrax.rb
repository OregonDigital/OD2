#class DefaultHyrax < ActiveFedora::Base
#  include ::Hyrax::WorkBehavior
#
#  self.indexer = DefaultHyraxIndexer
#  # Change this to restrict which works can be added as a child.
#  # self.valid_child_concerns = []
#  validates :title, presence: { message: 'Your work must have a title.' }
#
#  # This must be included at the end, because it finalizes the metadata
#  # schema (by adding accepts_nested_attributes)
#  include ::Hyrax::BasicMetadata
#end

class DefaultHyrax < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :label, Valkyrie::Types::String
  attribute :title, Valkyrie::Types::Set
  attribute :creator, Valkyrie::Types::Array.meta(ordered: true)

  # Hyrax/ActiveFedora, Dashboard view requires this for SOLR queries, it should return the class name like 'DefaultHyrax'
  def self.to_rdf_representation
    to_s
  end
end
