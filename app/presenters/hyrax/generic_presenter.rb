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
    delegate(:non_user_collections, to: :solr_document)
    delegate(:oai_collections, to: :solr_document)

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

    def total_viewable_items(id)
      visibility = ['open']
      visibility += current_ability&.current_user&.groups
      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id} AND suppressed_bsi:false AND visibility_ssi:(#{visibility.join(' ')})").accessible_by(current_ability).count
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
          begin
            prop.fetch
            solrized = prop.solrize
          rescue TriplestoreAdapter::TriplestoreException => e
            Rails.logger.warn "Failed to fetch #{prop_val} from cache AND source. #{e.message}"
          end
          label, source = split_solrized(solrized) || ['No label found', prop.rdf_subject.to_s]
          zipped[label] = source
        end
      end
      zipped
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def split_solrized(solrized)
      solrized&.[](1)&.[](:label)&.split('$')
    end

    def presentable?(presenter)
      (presenter.image? || presenter.pdf? || presenter.video? || presenter.audio?) && current_ability.can?(:read, presenter.id)
    end

    def oembed?(presenter)
      curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: presenter.id)
      !curation_concern.oembed_url.nil? && !curation_concern.oembed_url.empty? && current_ability.can?(:read, presenter.id)
    end
  end
end
