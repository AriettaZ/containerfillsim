class AddStepsToContainer < ActiveRecord::Migration
  def change
    add_column :containers, :steps, :integer, default: 5
  end
end
