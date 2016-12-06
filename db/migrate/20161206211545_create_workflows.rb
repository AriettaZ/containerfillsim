class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :type
      t.integer :status, default: 0
      t.integer :result, default: 0
      t.text :metadata

      t.timestamps null: false
    end
    add_index :workflows, :status
    add_index :workflows, :result
  end
end
