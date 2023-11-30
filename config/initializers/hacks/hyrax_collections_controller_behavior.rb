# frozen_string_literal:true

Rails.application.config.to_prepare do
  Hyrax::CollectionsController.class_eval { include ActionController::Live }
  Hyrax::CollectionsControllerBehavior.module_eval do

    # OVERRIDE FROM HYRAX
    # Remove :f (facets) from single item search to allow collection to verify user access
    def single_item_search_builder
      search_service.search_builder.with(params.except(:f, :q, :page))
    end

    # OVERRIDE FROM HYRAX
    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      # Set list of configured facets for the view to display
      presenter
      configured_facets
      query_collection_members
      respond_to do |wants|
        wants.html {render :show, status: :ok}
        wants.nt { render body: presenter.export_as_nt, mime_type: Mime[:nt] }
      end
    end

    # Zip up all works in collection into one collection zip
    def download
      zipname = "#{collection.id}.zip"

      send_file_headers!(
        type: 'application/zip',
        disposition: 'attachment',
        filename: zipname
      )
      response.headers['Last-Modified'] = Time.now.httpdate.to_s
      response.headers['X-Accel-Buffering'] = 'no'

      OregonDigital::CollectionStreamer.stream(collection) do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end

    # Get the path to institutional branding imag
    def institution_image_info
      image = 'no-institution-collection.png'
      alt = ''
      style = 'max-height: 45px;'

      case OregonDigital::InstitutionPicker.institution_acronym(@curation_concern)
      when 'OSU' then
        image = 'osu-collection.png'
        alt = 'Oregon State University Libraries and Press'
        style = 'max-height: 90px;'
      when 'UO'
        image = 'uo-collection.png'
        alt = 'University of Oregon Libraries'
      end unless @curation_concern.institution.first.nil?

      return ApplicationController.helpers.asset_path(image), alt, style
    end

    private

      # OVERRIDE FROM HYRAX
      # Point Blacklight searching to collection route
      def search_action_url options = {}
        hyrax.collection_url(options.except(:controller, :action))
      end

      def configured_facets
        @configured_facets ||= Facet.where(collection_id: collection.id, enabled: true).order(:order)
        @configured_facets.each do |facet|
          blacklight_config.facet_configuration_for_field(facet.solr_name).label = facet.label
          blacklight_config.facet_configuration_for_field(facet.solr_name).limit = -1
        end
      end
  end
end
