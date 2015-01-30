class AddStagedDirToContainer < ActiveRecord::Migration
  def up
    add_column :containers, :staged_dir, :string
    Container.find_each do |container|
      container.staged_dir = Pathname.new(container.jobs.first.job_path).to_s unless container.jobs.count == 0
      container.save!
    end
  end

  def down
    remove_column :containers, :staged_dir
  end
end
