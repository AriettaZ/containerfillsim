# This migration comes from ood_job_rails (originally 3)
class CreateOodJobRailsAttachments < ActiveRecord::Migration
  def change
    create_table :ood_job_rails_attachments do |t|
      t.string :type
      t.references :ood_job_rails_workflow, index: true, foreign_key: true
      t.text :file_data
      t.text :metadata

      t.timestamps null: false
    end
  end
end
