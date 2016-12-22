class MainJob < OodJobRails::Job
  # Workflow
  belongs_to :container, foreign_key: :ood_job_rails_workflow_id, inverse_of: :main_job

  # State
  enum status: [ :not_submitted, :completed, :queued, :queued_held, :suspended, :running ]
  enum result: [ :no_result, :passed, :failed ]

  # Metadata
  store :metadata, accessors: [ :job_id, :cluster_id ], coder: JSON

  # Update status of the job
  def update_status(stopped: false)
    status = OodJobRails::Adapter.status(cluster_id: cluster_id, job_id: job_id) unless stopped
    if stopped || status.undetermined?    # assume job finished it can't find job
      self.completed unless completed?
    elsif status.queued?
      self.queued! unless queued?
    elsif status.queued_held?
      self.queued_held? unless queued_held?
    elsif status.suspended?
      self.suspended! unless suspended?
    elsif status.running?
      self.running! unless running?
    end
  end

  # Stop the job
  def stop
    OodJobRails::Adapter.stop(cluster_id: cluster_id, job_id: job_id) && update_status(stopped: true)
  end

  # Handle completed job
  def completed
    self.completed!
    self.passed!
  end
end
