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
      title.first
    end

    # Link to add to shelf functionality
    def add_shelf_path
      # Links to item stats page until we have shelves
      Hyrax::Engine.routes.url_helpers.stats_work_path(self, locale: I18n.locale)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def zipped_values(prop_label)
      zipped = {}
      prop_label = prop_label.to_s.gsub('_label', '')
      send(prop_label).each do |prop_val|
        if Generic.properties[prop_label].class_name.nil?
          label = send(prop_label + '_label').first
          zipped[label] = prop_val
        else
          prop = Generic.properties[prop_label].class_name.new(prop_val)
          prop.fetch
          solrized = prop.solrize
          label, source = solrized[1][:label].split('$')
          zipped[label] = source
        end
      end
      zipped
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def presentable?(presenter)
      (presenter.image? || presenter.pdf? || presenter.video? || presenter.audio?) && current_ability.can?(:read, presenter.id)
    end

    def oembed?(presenter)
      ::FileSet.find(presenter.id).oembed? && current_ability.can?(:read, presenter.id)
    end
  end
end
