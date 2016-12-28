class Container < OodJobRails::Workflow
  # Attachments
  has_one :wall, foreign_key: :ood_job_rails_workflow_id, inverse_of: :container, dependent: :destroy
  has_many :inlets, foreign_key: :ood_job_rails_workflow_id, inverse_of: :container, dependent: :destroy
  accepts_nested_attributes_for :wall
  accepts_nested_attributes_for :inlets, allow_destroy: true

  # Jobs
  has_one :main_job, foreign_key: :ood_job_rails_workflow_id, inverse_of: :container, dependent: :destroy
  has_one :post_job, foreign_key: :ood_job_rails_workflow_id, inverse_of: :container, dependent: :destroy

  # Helper with list of all jobs (will loop over all jobs specified above)
  has_many :all_jobs, class_name: 'OodJobRails::Job', foreign_key: 'ood_job_rails_workflow_id'

  # State
  enum status: {
    not_submitted: 0,
    completed: 1,
    active: 2
  }
  enum result: {
    no_result: 0,
    passed: 1,
    failed: 2
  }

  # Metadata
  store :metadata, accessors: [ :name, :temperature ], coder: JSON
  validates :name, presence: true
  validates :temperature, presence: true
  validates :temperature, numericality: true

  # Hooks
  before_destroy :stop, prepend: true
  after_destroy  :unstage

  def main_script
    {
      content: root.join("main.sh"),
      workdir: root
    }
  end

  def post_script
    {
      content: root.join("post.sh"),
      workdir: root
    }
  end

  # Staging root for workflow
  def root
    OodAppkit.dataroot.join("containers", "#{id}_#{created_at.to_i}")
  end

  # Stage workflow
  def stage
    ContainersGenerator.new([self]).invoke_all
  end

  # Unstage workflow
  def unstage
    root.rmtree
  end

  # Submit workflow
  def submit
    # Job setup here
    build_main_job(OodJobRails::Adapter.new.submit(cluster_id: "oakley", script: main_script))
    build_post_job(OodJobRails::Adapter.new.submit(cluster_id: "oakley", script: post_script, afterok: main_job.job_id))
    self.active!
    true
  rescue OodJobRails::Adapter::Error => e
    self.stop
    msg = "An error occurred when submitting jobs for workflow #{id}: #{e.message}"
    errors.add(:base, msg) # must occur after any record manipulation
    Rails.logger.error(msg)
    false
  end

  # Stop workflow
  def stop
    return true if completed?
    all_jobs.each(&:stop)
    self.completed
    true
  rescue OodJobRails::Adapter::Error => e
    msg = "An error occurred when stopping jobs for workflow #{id}: #{e.message}"
    errors.add(:base, msg) # must occur after any record manipulation
    Rails.logger.error(msg)
    false
  end

  # Update workflow status
  def update_status
    return true if completed?
    all_jobs.each(&:update_status)
    self.completed if all_jobs.any? && all_jobs.all?(&:completed?)
    true
  rescue OodJobRails::Adapter::Error => e
    msg = "An error occurred when retrieving the status of jobs jobs for workflow #{id}: #{e.message}"
    errors.add(:base, msg) # must occur after any record manipulation
    Rails.logger.error(msg)
    false
  end

  # Handle completed workflow
  def completed
    self.completed!
    self.passed!
  end
end
