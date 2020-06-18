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

  def add_member_objects(new_member_ids)
    Array(new_member_ids).collect do |member_id|
      member = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: member_id, use_valkyrie: false)
      message = Hyrax::MultipleMembershipChecker.new(item: member).check(collection_ids: id, include_current_members: true)
      if message
        member.errors.add(:collections, message)
      else
        member.member_of_collections << self
        member.save!
      end
      member
    end
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
