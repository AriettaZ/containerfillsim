class CreateOutlets < ActiveRecord::Migration
  def change
    create_table :outlets do |t|
      t.float :pressure
      t.attachment :stl
      t.references :container, index: true

      t.timestamps
    end
  end
end
