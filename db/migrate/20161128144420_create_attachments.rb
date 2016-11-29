class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :type
      t.references :workflow, index: true
      t.text :file_data
      t.text :extend
    end
  end
end
