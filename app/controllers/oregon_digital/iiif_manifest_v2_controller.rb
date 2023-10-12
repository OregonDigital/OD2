# frozen_string_literal: true

require 'iiif_manifest'

module OregonDigital
  # display the v2 manifest, based mainly on old version of IIIFManifestControllerBehavior
  class IiifManifestV2Controller < ApplicationController
    # Steal the key prefix & some of the logic from Hyrax::CachingIiifManifestBuilder
    KEY_PREFIX = 'iiif-cache-v2'

    before_action :my_load_and_authorize_resource, only: [:show]

    def show
      headers['Access-Control-Allow-Origin'] = '*'
      expires_in = Hyrax.config.iiif_manifest_cache_duration || 12.hours

      json = Rails.cache.fetch(manifest_cache_key, expires_in: expires_in) do
        build_manifest
      end

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end

    def build_manifest
      manifest = manifest_builder.to_h
      manifest['thumbnail'] = thumbnail
      sanitize_manifest(JSON.parse(manifest.to_json))
    end

    def manifest_builder
      ::IIIFManifest::ManifestFactory.new(jp2_work_presenter)
    end

    def work
      @work ||= ActiveFedora::Base.find(params['id'])
    end

    def jp2_work_presenter
      return @jp2_work_presenter if @jp2_work_presenter

      @jp2_work_presenter = OregonDigital::IiifV2Presenter.new(@solrdoc, current_ability, request)
      @jp2_work_presenter.file_sets = @solrdoc.file_sets
      @jp2_work_presenter
    end

    def thumbnail
      id = @jp2_work_presenter.file_set_presenters.first.thumbnail_path
      { '@id': id, 'type': 'Image', 'format': 'image/jpg' }
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    def sanitize_manifest(hash)
      hash['label'] = sanitize_value(hash['label']) if hash.key?('label')
      hash['description'] = hash['description']&.collect { |elem| sanitize_value(elem) } if hash.key?('description')

      hash['sequences']&.each do |sequence|
        sequence['canvases']&.each do |canvas|
          canvas['label'] = sanitize_value(canvas['label'])
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

    private

    # struggling to rescue not found exceptions with authorize!
    # adapted from Hyrax::API::ItemsController
    # adding checking for model == Image
    def my_load_and_authorize_resource
      @solrdoc = SolrDocument.find(params['id'])
      return render plain: "access to #{@solrdoc.id} not authorized", status: :unauthorized unless current_ability.can? :read, @solrdoc

      return render plain: "manifest not supported for #{@solrdoc.id}", status: :unprocessable_entity unless @solrdoc.hydra_model == Image
    rescue Blacklight::Exceptions::RecordNotFound
      render plain: "id '#{params[:id]}' not found", status: :not_found
    end

    ##
    # @note adding a version_for suffix helps us manage cache expiration,
    #   reducing false cache hits
    #
    # @return [String]
    def manifest_cache_key
      "#{KEY_PREFIX}_#{@solrdoc.id}/#{version_for}"
    end

    ##
    # @note `etag` is a better option than the solr document `_version_`; the
    #   latter isn't always available, depending on how the presenter was
    #   built!
    #
    # @return [String]
    def version_for
      @solrdoc['_version_']
    end
  end
end
