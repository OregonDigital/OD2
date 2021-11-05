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

    def build_display_properties
      index = 0
      Generic::ORDERED_PROPERTIES.each do |prop|
        if prop[:is_controlled]
          build_controlled_prop(index)
        else
          presenter_value = presenter.attribute_to_html(prop[:name].to_sym, html_dl: true, label: t("simple_form.labels.defaults.#{prop[:name_label].nil? ? prop[:name] : prop[:name_label]}"))
          @props << prop unless presenter_value.nil? || presenter_value.empty?
        end
      end
    end

    def build_controlled_prop(index)
      zipped = presenter.zipped_values(prop[:name])
      return if zipped.nil? || zipped.empty?

      prop[:indices] = {}
      zipped.each do |_value, uri|
        prop[:indices][uri] = index
        index += 1
      end
      @props << prop
    end
  end
end
