# frozen_string_literal:true

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
    cms = collection_member_service

    zip = Zip::OutputStream.write_buffer do |zio|
      # Add the metadata
      zio.put_next_entry('metadata.csv')
      zio.write collection.csv_metadata

      # Add each file
      cms.available_member_works.documents.each do |solr_doc|
        work = ActiveFedora::Base.find(solr_doc.id)
        # Skip adding works that the user can't download
        next unless current_ability.can? :download, work
        zio.put_next_entry("#{work.id}.zip")
        zio.write work.zip_files.string
      end
    end
    send_data zip.string, filename: "#{collection.id}.zip"
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
