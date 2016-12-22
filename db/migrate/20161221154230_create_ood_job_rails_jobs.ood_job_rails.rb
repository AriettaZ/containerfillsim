# This migration comes from ood_job_rails (originally 2)
class CreateOodJobRailsJobs < ActiveRecord::Migration
  def change
    create_table :ood_job_rails_jobs do |t|
      t.string :type
      t.integer :status, default: 0
      t.integer :result, default: 0
      t.text :file_data
      t.text :metadata
      t.references :ood_job_rails_workflow, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
