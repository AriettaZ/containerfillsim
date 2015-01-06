class RemoveInletOutletFromContainer < ActiveRecord::Migration
  def change
    remove_column :containers, :inlet_vx, :float
    remove_column :containers, :inlet_vy, :float
    remove_column :containers, :inlet_vz, :float
    remove_column :containers, :outlet_pressure, :float
    remove_attachment :containers, :inlet
    remove_attachment :containers, :outlet
  end
end
