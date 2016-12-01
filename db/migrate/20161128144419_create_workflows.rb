class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :type
      t.string :root
      t.integer :status, default: 0
      t.integer :result, default: 0
      t.text :metadata
    end
  end
end
