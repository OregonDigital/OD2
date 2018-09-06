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

require 'ostruct'

class DefaultHyrax < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  # Hyrax default metadata
  attribute :admin_set_id, Valkyrie::Types::String
  # Hyrax default metadata
  attribute :depositor, Valkyrie::Types::String
  attribute :creator, Valkyrie::Types::Array.meta(ordered: true)
  attribute :label, Valkyrie::Types::String
  # Hyrax default metadata
  attribute :member_of_collection_ids, Valkyrie::Types::Set
  attribute :title, Valkyrie::Types::Set

  # Hyrax forms need to know if this is a new record or not
  def new_record?
    new_record
  end

  # Hyrax/ActiveFedora, Dashboard view requires this for SOLR queries, it should return the class name like 'DefaultHyrax'
  def self.to_rdf_representation
    to_s
  end

  def self.properties
    {
      admin_set_id: {
        multiple: false
      },
      depositor: {
        multiple: false
      },
      creator: {
        multiple: true
      },
      label: {
        multiple: false
      },
      member_of_collection_ids: {
        multiple: true
      },
      title: {
        multiple: true
      }
    }
  end

  def self.reflect_on_association(field)
    nil
  end

  def self.attribute_names
    %w[
      admin_set_id
      depositor
      creator
      label
      member_of_collection_ids
      title
    ]
  end

  def self.multiple?(field)
    self.properties[field][:multiple]
  end

  def errors
    ValkyrieError.new
  end
end

class ValkyrieError
  def [](field)
    fields = {
      admin_set_id: [],
      depositor: [],
      creator: [],
      label: [],
      member_of_collection_ids: [],
      title: []
    }
    fields[field]
  end

  def full_messages_for(field)
  end

  def any?
    false
  end

  def present?
    false
  end
end