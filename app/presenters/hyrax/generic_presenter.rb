# frozen_string_literal:true

module Hyrax
  # Display config for generic object
  class GenericPresenter < Hyrax::WorkShowPresenter
    delegate(*Generic.generic_properties.map(&:to_sym), to: :solr_document)
    delegate(*Generic.controlled_property_labels.map(&:to_sym), to: :solr_document)
    delegate(:type_label, to: :solr_document)
    delegate(:rights_statement_label, to: :solr_document)
    delegate(:language_label, to: :solr_document)

    # Returns true if any fileset is an image or PDF, both of which will always
    # have one or more JP2s
    def iiif_viewer?
      file_set_presenters.any? do |presenter|
        (presenter.image? || presenter.pdf?) && current_ability.can?(:read, presenter.id)
      end
    end
  end
end
