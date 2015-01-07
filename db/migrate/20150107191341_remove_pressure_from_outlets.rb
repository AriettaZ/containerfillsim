class RemovePressureFromOutlets < ActiveRecord::Migration
  def change
    remove_column :outlets, :pressure, :float
  end
end
