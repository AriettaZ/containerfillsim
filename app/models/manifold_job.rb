class ManifoldJob < OodJobRails::Job
  # Workflow
  belongs_to :manifold, foreign_key: :ood_job_rails_workflow_id, inverse_of: :manifold_job

  # State
  enum status: {
    not_submitted: 0,
    completed: 1,
    queued: 2,
    queued_held: 3,
    suspended: 4,
    running: 5
  }
  enum result: {
    no_result: 0,
    passed: 1,
    failed: 2
  }

  # Metadata
  store :metadata, accessors: [ :job_id, :cluster_id ], coder: JSON

  # Cluster
  def cluster_id
    super || "oakley"
  end

  # Script
  def script
    {
      content: manifold.root.join("main.sh"),
      workdir: manifold.root
    }
  end

  # Submit the job
  def submit(opts = {})
    self.cluster_id = cluster_id
    self.job_id     = OodJobRails::Adapter.new.submit(cluster_id: cluster_id, script: script, **opts)
  end

  # Update status of the job
  def update_status
    return if completed?
    status = OodJobRails::Adapter.new.status(cluster_id: cluster_id, job_id: job_id)
    if status.undetermined?    # assume job finished it can't find job
      self.completed unless completed?
    elsif status.queued?
      self.queued! unless queued?
    elsif status.queued_held?
      self.queued_held! unless queued_held?
    elsif status.suspended?
      self.suspended! unless suspended?
    elsif status.running?
      self.running! unless running?
    end
  end

  # Stop the job
  def stop
    return if completed?
    OodJobRails::Adapter.new.stop(cluster_id: cluster_id, job_id: job_id) && completed
  end

  # Handle completed job
  def completed
    self.completed!
    self.passed!
  end
end
