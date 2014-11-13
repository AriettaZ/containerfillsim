class RenameMeasurementColumnOnContainer < ActiveRecord::Migration
  def change
    rename_column :containers, :measurement, :measurement_scale
  end
end
