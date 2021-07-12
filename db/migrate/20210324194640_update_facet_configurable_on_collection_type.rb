class UpdateFacetConfigurableOnCollectionType < ActiveRecord::Migration[5.2]
  def change
    change_column_null :hyrax_collection_types, :facet_configurable, false, false
    change_column_default :hyrax_collection_types, :facet_configurable, from: nil, to: true
  end
end
