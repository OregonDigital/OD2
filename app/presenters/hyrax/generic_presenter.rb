# frozen_string_literal:true

module Hyrax
  # Display config for generic object
  class GenericPresenter < Hyrax::WorkShowPresenter
    delegate(*Generic.generic_properties.map(&:to_sym), to: :solr_document)
    delegate(*Generic.controlled_property_labels.map(&:to_sym), to: :solr_document)
    delegate(:type_label, to: :solr_document)
    delegate(:rights_statement_label, to: :solr_document)
    delegate(:language_label, to: :solr_document)
  end
end
