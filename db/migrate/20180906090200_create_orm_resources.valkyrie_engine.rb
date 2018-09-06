# frozen_string_literal: true

class CreateOrmResources < ActiveRecord::Migration[5.0]
  def change
    create_table :orm_resources, id: :uuid do |t|
      t.jsonb :metadata, null: false, default: {}
      t.integer :lock_version
      t.string :internal_resource
      t.timestamps
    end
    add_index :orm_resources, "metadata jsonb_path_ops", using: :gin
    add_index :orm_resources, :updated_at
    add_index :orm_resources, :internal_resource
  end
end
