class AddAttachmentInletOutletWallsToContainers < ActiveRecord::Migration
  def self.up
    change_table :containers do |t|
      t.attachment :inlet
      t.attachment :outlet
      t.attachment :walls
    end
  end

  def self.down
    drop_attached_file :containers, :inlet
    drop_attached_file :containers, :outlet
    drop_attached_file :containers, :walls
  end
end
