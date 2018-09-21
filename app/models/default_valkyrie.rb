# frozen_string_literal: true

require 'ostruct'

class DefaultValkyrie < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :admin_set_id, Valkyrie::Types::String
  attribute :based_near, Valkyrie::Types::Array
  attribute :date_modified, Valkyrie::Types::String
  attribute :date_uploaded, Valkyrie::Types::String
  attribute :depositor, Valkyrie::Types::String
  attribute :creator, Valkyrie::Types::Array.meta(ordered: true)
  attribute :hasModel, Valkyrie::Types::String
  attribute :label, Valkyrie::Types::String
  attribute :language, Valkyrie::Types::Array
  attribute :license, Valkyrie::Types::Set
  attribute :member_of_collection_ids, Valkyrie::Types::Set
  attribute :subject, Valkyrie::Types::Array
  attribute :title, Valkyrie::Types::Set
  attribute :visibility, Valkyrie::Types::String

  def attributes_for_hyrax
    to_h.except(*self.class.reserved_attributes + %i[member_of_collection_ids hasModel])
        .merge({ id: id.to_s })
  end
end
