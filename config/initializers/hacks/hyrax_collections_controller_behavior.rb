# frozen_string_literal:true

Hyrax::CollectionsController.class_eval { include ActionController::Live }
Hyrax::CollectionsControllerBehavior.module_eval do

  # OVERRIDE FROM HYRAX
  # Remove :f (facets) from single item search to allow collection to verify user access
  def single_item_search_builder
    single_item_search_builder_class.new(self).with(params.except(:f, :q, :page))
  end

  # OVERRIDE FROM HYRAX
  def show
    @curation_concern ||= ActiveFedora::Base.find(params[:id])
    # Set list of configured facets for the view to display
    presenter
    query_collection_members
    configured_facets
  end

  # Zip up all works in collection into one collection zip
  def download
    zipname = "#{collection.id}.zip"

    send_file_headers!(
      type: "application/zip",
      disposition: "attachment",
      filename: zipname
    )
    response.headers["Last-Modified"] = Time.now.httpdate.to_s
    response.headers["X-Accel-Buffering"] = "no"

    OregonDigital::CollectionStreamer.stream(collection) do |chunk|
      response.stream.write(chunk)
    end
  ensure
    response.stream.close
  end

  # Get the path to institutional branding imag
  def institution_image_path
    image = 'no-institution-collection.png'

    case @curation_concern.institution.first.label
    when 'Oregon State University' then
      image = 'osu-collection.png'
    when 'University of Oregon'
      image = 'uo-collection.png'
    end unless @curation_concern.institution.first.nil?

    ApplicationController.helpers.asset_path(image)
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
      end
    end
end
