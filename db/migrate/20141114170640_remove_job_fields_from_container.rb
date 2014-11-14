class RemoveJobFieldsFromContainer < ActiveRecord::Migration
  def change
    remove_column :containers, :status
    remove_column :containers, :pbsid
    remove_column :containers, :job_path
  end
end
