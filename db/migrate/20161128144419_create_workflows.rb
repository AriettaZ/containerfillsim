class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :type
      t.string :root
      t.integer :status, default: 0
      t.text :jobs
      t.text :extend
    end
  end
end
