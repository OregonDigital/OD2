class CreateCollectionRepresentatives < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_representatives do |t|
      t.string :collection_id
      t.string :fileset_id
      t.int    :order

      t.timestamps
    end
  end
end
