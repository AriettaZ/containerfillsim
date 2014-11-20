class RemoveDefaultFromSteps < ActiveRecord::Migration
  def change
    change_column_default :containers, :steps, nil
  end
end
