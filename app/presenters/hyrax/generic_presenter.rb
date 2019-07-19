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

    def page_title
      "#{title.first} | #{I18n.t('hyrax.product_name')}"
    end

    # Link to add to shelf functionality
    def add_shelf_path
      # Links to item stats page until we have shelves
      Hyrax::Engine.routes.url_helpers.stats_work_path(self, locale: I18n.locale)
    end
  end
end
