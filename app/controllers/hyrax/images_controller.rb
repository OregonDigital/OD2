# frozen_string_literal:true

module Hyrax
  # Generated controller for Image
  class ImagesController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::DownloadControllerBehavior
    prepend OregonDigital::WorksControllerBehavior
    include OregonDigital::WorkRelationPaginationBehavior
    self.curation_concern_type = ::Image

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    def show
      @props = []
      index = 0
      Generic::ORDERED_PROPERTIES.each do |prop|
        if prop[:is_controlled]
          presenter_value = Array(presenter.send(prop[:name].to_sym))
          zipped = presenter.zipped_values(prop[:name])
          unless zipped.nil? || zipped.empty?
            prop[:indices] = {}
            zipped.each do |value, uri|
              prop[:indices][uri] = index
              index += 1
            end
            @props << prop
          end
        else
          presenter_value = presenter.attribute_to_html(prop[:name].to_sym, html_dl: true, label: t("simple_form.labels.defaults.#{prop[:name_label].nil? ? prop[:name] : prop[:name_label]}"))
          unless presenter_value.nil? || presenter_value.empty?
            @props << prop
          end
        end
      rescue NoMethodError
      end

      super
    end

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter
  end
end
