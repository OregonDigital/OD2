class CreateFacets < ActiveRecord::Migration[5.1]
  def change
    create_table :facets do |t|
      t.string :property_name
      t.string :label
      t.string :solr_name
      t.string :collection_id
      t.integer :order, default: 999
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
