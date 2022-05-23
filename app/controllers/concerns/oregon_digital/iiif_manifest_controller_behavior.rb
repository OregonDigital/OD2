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
      manifest_json['items'] = with_thumbnails(manifest_json['items'].to_json)
      json = sanitize_manifest(JSON.parse(manifest_json.to_json))

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end

    ###
    # Gets the external thumbnail path of a resource.
    def with_thumbnails(items)
      JSON.parse(items)
      items.each do |item|
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
      work = solrdoc.hydra_model.find(solrdoc.id)
      @jp2_work_presenter.file_sets = work.file_sets
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
