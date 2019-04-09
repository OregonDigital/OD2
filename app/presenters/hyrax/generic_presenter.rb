# frozen_string_literal:true

module Hyrax
  # Display config for generic object
  class GenericPresenter < Hyrax::WorkShowPresenter
    delegate(*Generic.generic_properties.map(&:to_sym), to: :solr_document)
    delegate(*Generic.controlled_props.map(&:to_sym), to: :solr_document)
  end
end
