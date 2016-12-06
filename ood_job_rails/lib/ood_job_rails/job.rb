module OodJobRails
  class Job < ActiveRecord::Base
    belongs_to :workflow, inverse_of: :jobs

    enum status: [ :not_submitted, :queued, :queued_held, :suspended, :running, :completed ]
    enum result: [ :no_result, :passed, :failed ]

    store :metadata, accessors: [ :job_id, :cluster_id ], coder: JSON

    define_model_callbacks :completed

    # Maps what the JobHandler returns after getting an OodJob::Status object
    # to defined status values in the enum
    def self.status_mapping
      {
        "queued"      => :queued,
        "queued_held" => :queued_held,
        "suspended"   => :suspended,
        "running"     => :running,
        "completed"   => :completed
      }
    end

    def active?
      !not_submitted? && !completed?
    end

    def stopped
      completed unless completed?
    end

    # Change the status of this job and save the record if the status has
    # changed
    def update_status(status)
      return false if status.nil?
      status_method = self.class.status_mapping[status.to_s]
      if status_method == :completed
        completed unless completed?
      else
        send("#{status_method}!") unless send("#{status_method}?")
      end
      true
    end

    # Set job to completed status
    def completed
      run_callbacks :completed do
        self.completed!
        self.passed!
      end
    end
  end
end
