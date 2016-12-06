class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :type
      t.references :workflow, index: true, foreign_key: true
      t.text :file_data
      t.text :metadata

      t.timestamps null: false
    end
  end
end
