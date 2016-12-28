class Manifold < OodJobRails::Workflow
  # Jobs
  has_one :manifold_job, foreign_key: :ood_job_rails_workflow_id, inverse_of: :manifold, dependent: :destroy

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
  store :metadata, accessors: [ :name, :speed ], coder: JSON
  validates :name, presence: true
  validates :speed, presence: true
  validates :speed, numericality: true

  # Hooks
  before_destroy :stop, prepend: true
  after_destroy  :unstage

  def script
    {
      content: root.join("main.sh"),
      workdir: root
    }
  end

  # Staging root for workflow
  def root
    OodAppkit.dataroot.join("manifold", "#{id}_#{created_at.to_i}")
  end

  # Stage workflow
  def stage
    ManifoldsGenerator.new([self]).invoke_all
  end

  # Unstage workflow
  def unstage
    root.rmtree
  end

  # Submit workflow
  def submit
    # Job setup here
    build_manifold_job(OodJobRails::Adapter.new.submit(cluster_id: "oakley", script: script))
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
    manifold_job.stop
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
    manifold_job.update_status
    self.completed if manifold_job.completed?
    true
  rescue OodJobRails::Adapter::Error => e
    msg = "An error occurred when retrieving the status of jobs for workflow #{id}: #{e.message}"
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
