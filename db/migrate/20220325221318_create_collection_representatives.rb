class CreateCollectionRepresentatives < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_representatives do |t|
      t.string  :collection_id, null: false
      t.string  :fileset_id, null: false
      t.integer :order, null: false

      t.timestamps
    end
  end
end
