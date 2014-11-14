class AddScriptNameToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :script_name, :string
  end
end
