class CreateHyraxMigratorWorks < ActiveRecord::Migration[5.1]
  def change
    create_table :hyrax_migrator_works do |t|
      t.string :pid, null: false, index: { unique: true }
      t.string :file_path
      t.string :aasm_state
      t.string :status_message
      t.string :status
      t.text :env

       t.timestamps
    end
  end
end