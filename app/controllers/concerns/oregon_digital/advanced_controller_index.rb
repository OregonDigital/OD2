# frozen_string_literal:true

module OregonDigital
  # Modules for OregonDigital
  module AdvancedControllerIndex
    # Prepend to BlacklightAdvancedSearch::AdvancedController to get breadcrumb
    def index
      blacklight_config.facet_fields.map do |_k, facet|
        facet.limit = -1
      end

      @response = get_advanced_search_facets unless request.method == :post
      add_breadcrumb t('hyrax.controls.advanced'), 'advanced'
    end
  end
end
