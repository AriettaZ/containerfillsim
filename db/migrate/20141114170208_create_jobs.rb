class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :status
      t.string :pbsid
      t.string :job_path
      t.references :container, index: true

      t.timestamps
    end
  end
end
