class RemoveRootFromWorkflow < ActiveRecord::Migration
  def change
    remove_column :workflows, :root, :string
  end
end
