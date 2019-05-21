class AddConfigurableToCollectionType < ActiveRecord::Migration[5.1]
  def change
    add_column :hyrax_collection_types, :configurable, :boolean
  end
end
