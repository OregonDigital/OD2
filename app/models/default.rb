# frozen_string_literal: true

class Default < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :title, Valkyrie::Types::Set
  attribute :creator, Valkyrie::Types::Array.meta(ordered: true)
  attribute :date, Valkyrie::Types::Array
end
