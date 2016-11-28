require 'pathname'
require 'securerandom'
require 'ood_job_rails'

class Workflow < ActiveRecord::Base
  include OodJobRails::JobHandler

  enum status: {
    not_submitted: 0,
    active: 10,
    completed: 20
  }

  store :jobs,        accessors: [], coder: JSON
  store :extend,      accessors: [], coder: JSON

  after_commit :set_root, on: :create
  before_destroy { |workflow| workflow.stop }
  after_destroy  { |workflow| workflow.root.rmtree if workflow.root.exist? }

  def set_root
    # avoid infinite callback
    update_column :root, File.join(self.class.name.tableize, "#{id}_#{Time.now.to_i}")
  end

  def root
    if super
      path = OodAppkit.dataroot.join(super)
      path.mkpath # make root path if doesn't exist
      path
    end
  end

  def cluster(id)
    OodAppkit.clusters[id]
  end
end
