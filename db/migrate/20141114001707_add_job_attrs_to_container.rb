class AddJobAttrsToContainer < ActiveRecord::Migration
  def change
    add_column :containers, :status, :string
    add_column :containers, :pbsid, :string
    add_column :containers, :job_path, :string
  end
end
