class CreateInlets < ActiveRecord::Migration
  def change
    create_table :inlets do |t|
      t.float :vx
      t.float :vy
      t.float :vz
      t.attachment :stl
      t.references :container, index: true

      t.timestamps
    end
  end
end
