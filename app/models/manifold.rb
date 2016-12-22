class Manifold < OodJobRails::Workflow
  # Jobs
  has_one :manifold_job, foreign_key: :ood_job_rails_workflow_id, inverse_of: :manifold, dependent: :destroy

  # State
  enum status: [ :not_submitted, :completed, :active ]
  enum result: [ :no_result, :passed, :failed ]

  # Metadata
  store_accessor :metadata, :name, :speed
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
    OodJobRails.dataroot.join("manifold", "#{id}_#{created_at.to_i}")
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
    build_manifold_job(OodJobRails::Adapter.submit(cluster_id: "oakley", script: script))
    self.active!
    true
  rescue OodJobRails::Adapter::Error => e
    OodJobRails::WorkflowError.call(self, e, when: 'submitting jobs')
    self.stop
    false
  end

  # Stop workflow
  def stop
    return true if completed?
    manifold_job.stop unless manifold_job.completed?
    self.completed
    true
  rescue OodJobRails::Adapter::Error => e
    OodJobRails::WorkflowError.call(self, e, when: 'stopping jobs')
    false
  end

  # Update workflow status
  def update_status
    return true if completed?
    manifold_job.update_status unless manifold_job.completed?
    self.completed if manifold_job.completed?
    true
  rescue OodJobRails::Adapter::Error => e
    OodJobRails::WorkflowError.call(self, e, when: 'retrieving the status of jobs')
    false
  end

  # Handle completed workflow
  def completed
    self.completed!
    self.passed!
  end
end
