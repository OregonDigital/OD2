# frozen_string_literal:true

module OregonDigital
  # Builds displayed properties with citation indices
  module PresentsDataSources
    extend ActiveSupport::Concern

    def show
      @props = []
      build_display_properties

      super
    end

    # rubocop:disable Metrics/AbcSize
    def build_display_properties
      index = 1
      # FETCH: Get the label$uri from SolrDocument
      cv_label_uris = SolrDocument.find(presenter.id)

      Generic::ORDERED_PROPERTIES.each do |prop|
        if prop[:is_controlled]
          index = build_controlled_prop(index, prop, cv_label_uris)
        else
          presenter_value = presenter.attribute_to_html(prop[:name].to_sym, html_dl: true, label: t("simple_form.labels.defaults.#{prop[:name_label].nil? ? prop[:name] : prop[:name_label]}"))
          @props << prop unless presenter_value.nil? || presenter_value.empty?
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def build_controlled_prop(index, prop, cv_label_uris)
      # GET: Get the 'label$uri' from specific controlled vocab
      parse_cv = cv_label_uris.label_uri_helpers(prop[:name].gsub('_label', ''))

      # CHECK: Return index if either parse_cv is empty or nil
      return index if parse_cv.nil? || parse_cv.empty?

      # SETUP & LOOP: Setup the indices storage and loop through each parse_cv
      prop[:indices] = {}
      parse_cv.each do |value|
        prop[:indices][value['uri']] = index
        index += 1
      end
      @props << prop
      index
    end
  end
end
