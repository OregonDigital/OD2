# frozen_string_literal:true

require 'iiif_manifest'

module OregonDigital
  # IIIFManifestControllerBehavior mixes in logic to generate a IIIF manifest
  # without the incorrect assumptions the Hyrax defaults make
  module IIIFManifestControllerBehavior
    extend ActiveSupport::Concern
    included do
      before_action :redirect_json, only: :manifest
    end

    def manifest
      headers['Access-Control-Allow-Origin'] = '*'

      manifest_json = manifest_builder.to_h
      # Thumbnails are not supported by iiif_manifest V3
      # https://github.com/samvera/iiif_manifest/issues/34
      manifest_json['items'] = items_with_thumbnails(manifest_json['items'].to_json) unless manifest_json['items'].blank?
      json = sanitize_manifest(JSON.parse(manifest_json.to_json))

      respond_to do |wants|
        wants.json { render json: json }
      end
    end

    def redirect_json
      return if request.format.json?

      redirect_to main_app.polymorphic_url [:manifest, :hyrax, controller_name.singularize], { locale: nil, format: :json }
    end

    ###
    # Gets the external thumbnail path of a resource.
    def items_with_thumbnails(items)
      items = JSON.parse(items)
      items&.each do |item|
        path = item.dig('items', 0, 'items', 0, 'body', 'id')
        next nil if path.nil?

        item['thumbnail'] = [{ 'id': path,
                               'type': 'Image',
                               'format': 'image/jpg' }]
      end
      items
    end

    def manifest_builder
      ::IIIFManifest::V3::ManifestFactory.new(jp2_work_presenter)
    end

    def jp2_work_presenter
      return @jp2_work_presenter if @jp2_work_presenter

      solrdoc = search_result_document(params)
      @jp2_work_presenter = OregonDigital::IIIFPresenter.new(solrdoc, current_ability, request)
      @jp2_work_presenter.file_sets = solrdoc.file_sets
      @jp2_work_presenter
    end

    def sanitize_manifest(hash)
      sanitize_manifest_label(hash)
      hash
    end

    def sanitize_manifest_label(hash)
      hash['label']&.each do |lang, labels|
        labels&.each_with_index do |label, i|
          hash['label'][lang][i] = sanitize_value(label) if hash.key?('label')
        end
      end
    end

    def sanitize_manifest_items(hash)
      hash['items']&.each do |item|
        item['label']&.each do |lang, labels|
          labels&.each_with_index do |label, i|
            item['label'][lang][i] = sanitize_value(label)
          end
        end
      end
    end

    def sanitize_value(text)
      Loofah.fragment(text.to_s).scrub!(:prune).to_s
    end
  end
end
