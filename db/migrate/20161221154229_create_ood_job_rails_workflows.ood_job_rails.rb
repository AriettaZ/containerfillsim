# This migration comes from ood_job_rails (originally 1)
class CreateOodJobRailsWorkflows < ActiveRecord::Migration
  def change
    create_table :ood_job_rails_workflows do |t|
      t.string :type
      t.integer :status, default: 0
      t.integer :result, default: 0
      t.text :metadata

      t.timestamps null: false
    end
    add_index :ood_job_rails_workflows, :status
    add_index :ood_job_rails_workflows, :result
  end
end
