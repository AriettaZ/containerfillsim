class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :type
      t.references :workflow, index: true, foreign_key: true
      t.integer :status, default: 0
      t.integer :result, default: 0
      t.text :metadata

      t.timestamps null: false
    end
    add_index :jobs, :status
    add_index :jobs, :result
  end
end
