module OregonDigital::FacetHelperBehavior
  def render_facet_item(facet_field, item)
    if facet_in_params?(facet_field, item.value)
      render_selected_facet_value(facet_field, item)
    else
      render_facet_value(facet_field, item) unless is_user_collection?(facet_field, item.value)
    end
  end

  def is_user_collection?(facet_field, item_value)
    facet_field == 'member_of_collections_ssim' && Collection.where(title: item_value).first.collection_type.machine_id == 'user_collection'
  end
end