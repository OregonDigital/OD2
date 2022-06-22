# frozen_string_literal:true

module Hyrax
  # Display config for generic object
  class GenericPresenter < Hyrax::WorkShowPresenter
    include OregonDigital::PresentsAttributes
    include Hyrax::WithEvents
    delegate(*Generic.generic_properties.map(&:to_sym), to: :solr_document)
    delegate(*Generic.controlled_properties.map(&:to_sym), to: :solr_document)
    delegate(*Generic.controlled_property_labels.map(&:to_sym), to: :solr_document)
    delegate(:resource_type_label, to: :solr_document)
    delegate(:rights_statement_label, to: :solr_document)
    delegate(:language_label, to: :solr_document)

    # Returns true if any fileset or any child work has a filset that is an image or PDF,
    # both of which will always have one or more JP2s
    def iiif_viewer?
      fileset_viewable = file_set_presenters.any? do |presenter|
        presentable?(presenter)
      end
      work_viewable = work_presenters.any? do |work_presenter|
        work_presenter.file_set_presenters.any? do |presenter|
          presentable?(presenter)
        end
      end
      fileset_viewable || work_viewable
    end

    def oembed_viewer?
      file_set_presenters.any? do |presenter|
        oembed?(presenter)
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

    def zipped_values(prop)
      labels = Array(send(prop))
      links = Array(send(prop.to_s.gsub('_label', '')))
      zipped = labels.zip(links)
      Hash[zipped]
    end

    private

    def presentable?(presenter)
      (presenter.image? || presenter.pdf? || presenter.video? || presenter.audio?) && current_ability.can?(:read, presenter.id)
    end

    def oembed?(presenter)
      ::FileSet.find(presenter.id).oembed? && current_ability.can?(:read, presenter.id)
    end
  end
end
