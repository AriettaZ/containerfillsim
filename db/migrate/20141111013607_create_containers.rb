class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :name
      t.string :measurement
      t.string :fluid_type
      t.float :kinematic_viscosity
      t.float :density
      t.float :outlet_pressure
      t.float :inlet_vx
      t.float :inlet_vy
      t.float :inlet_vz

      t.timestamps
    end
  end
end
