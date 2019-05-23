class AddFacetConfigurableToCollectionType < ActiveRecord::Migration[5.1]
  def change
    add_column :hyrax_collection_types, :facet_configurable, :boolean
  end
end
