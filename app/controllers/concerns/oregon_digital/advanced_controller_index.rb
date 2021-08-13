# frozen_string_literal:true

module OregonDigital::AdvancedControllerIndex
  # Prepend to BlacklightAdvancedSearch::AdvancedController to get breadcrumb
  def index
    @response = get_advanced_search_facets unless request.method == :post
    add_breadcrumb t('hyrax.controls.advanced'), 'advanced'
  end
end
