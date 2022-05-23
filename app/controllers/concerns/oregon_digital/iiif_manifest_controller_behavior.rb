# frozen_string_literal:true

require 'iiif_manifest'

module OregonDigital
  # IIIFManifestControllerBehavior mixes in logic to generate a IIIF manifest
  # without the incorrect assumptions the Hyrax defaults make
  module IIIFManifestControllerBehavior
    def manifest
      headers['Access-Control-Allow-Origin'] = '*'

      manifest_json = manifest_builder.to_h
      # Thumbnails are not supported by iiif_manifest V3
      # https://github.com/samvera/iiif_manifest/issues/34
      # So we'll add our own
      manifest_json['items'].each_with_index do |item, i|
        item['thumbnail'] = thumbnail JSON.parse(item.to_json)
      end
      json = sanitize_manifest(JSON.parse(manifest_json.to_json))

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end

    ###
    # Gets the external thumbnail path of a resource.
    def thumbnail(item)
      path = item.dig('items', 0, 'items', 0, 'body', 'id')
      return nil if path.nil?
      [
        {
          "id": path,
          "type": "Image",
          "format": "image/jpg"
        }
      ]
    end

    def manifest_builder
      ::IIIFManifest::V3::ManifestFactory.new(jp2_work_presenter)
    end

    def jp2_work_presenter
      return @jp2_work_presenter if @jp2_work_presenter

      solrdoc = search_result_document(params)
      @jp2_work_presenter = OregonDigital::IIIFPresenter.new(solrdoc, current_ability, request)
      work = solrdoc.hydra_model.find(solrdoc.id)
      @jp2_work_presenter.file_sets = work.file_sets
      @jp2_work_presenter
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    def sanitize_manifest(hash)
      hash['label']&.each do |lang, labels|
        labels&.each_with_index do |label, i|
          hash['label'][lang][i] = sanitize_value(label) if hash.key?('label')
        end
      end
      hash['description'] = hash['description']&.collect { |elem| sanitize_value(elem) } if hash.key?('description')

      hash['items']&.each do |item|
        item['label']&.each do |lang, labels|
          labels&.each_with_index do |label, i|
            item['label'][lang][i] = sanitize_value(label)
          end
        end
      end
      hash
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity

    def sanitize_value(text)
      Loofah.fragment(text.to_s).scrub!(:prune).to_s
    end
  end
end
