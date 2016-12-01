class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :type
      t.references :workflow, index: true
      t.integer :status, default: 0
      t.integer :result, default: 0
      t.text :metadata
    end
  end
end
