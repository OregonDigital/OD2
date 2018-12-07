class CreateOembedErrors < ActiveRecord::Migration[5.1]
  def change
    create_table :oembed_errors do |t|
      t.string :document_id
      t.text :oembed_errors

      t.timestamps
    end
    add_index :oembed_errors, :document_id, unique: true
  end
end
