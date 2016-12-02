class AddTimestampsToSchema < ActiveRecord::Migration
  def change
    add_timestamps :attachments
    add_timestamps :jobs
    add_timestamps :workflows
  end
end
