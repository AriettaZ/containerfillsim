class ChangeContainerStepsDefaultValue < ActiveRecord::Migration
  def change
    change_column_default :containers, :steps, 5
  end
end
