class PostJob < OodJobRails::Job
  # Workflow
  belongs_to :container, foreign_key: :ood_job_rails_workflow_id, inverse_of: :post_job

  # State
  enum result: [ :no_result, :passed, :failed ]

  # Metadata
  # store_accessor :metadata, :nodes, :walltime

  # Hooks
  after_completed :validate_job

  # Validate job results here
  def validate_job
    self.passed!
  end
end
