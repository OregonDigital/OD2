# frozen_string_literal:true

# Helper methods for the advanced search form
module AdvancedHelper
  include BlacklightAdvancedSearch::AdvancedHelperBehavior

  def select_menu_for_field_operator
    options = {
      t('blacklight_advanced_search.all') => 'AND',
      t('blacklight_advanced_search.any') => 'OR'
    }.sort

    select_tag(:op, options_for_select(options, params[:op]), class: 'input-small', aria: { description: 'scope' })
  end
end
