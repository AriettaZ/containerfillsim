class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :type
      t.references :workflow, index: true
      t.string :file_id
      t.string :file_filename
      t.integer :file_size
      t.string :file_content_type
      t.text :extend
    end
  end
end
