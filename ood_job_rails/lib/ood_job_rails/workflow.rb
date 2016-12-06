module OodJobRails
  class Workflow < ActiveRecord::Base
    include JobHandler

    has_many :jobs, inverse_of: :ood_job_rails_workflow, dependent: :destroy

    enum status: [ :not_submitted, :active, :completed ]
    enum result: [ :no_result, :passed, :failed ]

    store :metadata, accessors: [], coder: JSON

    before_destroy :clean_up_jobs, prepend: true    # run this before destroying jobs
    after_destroy :clean_up_files

    define_model_callbacks :completed

    def root
      OodJobRails.dataroot.join(self.class.name.tableize).join("#{id}_#{created_at.to_i}")
    end

    def clean_up_jobs
      stop
    end

    def clean_up_files
      root.rmtree
    end

    # Stop workflow
    def stop
      return true if completed?
      jobs.each do |job|
        stop_job(job) unless job.completed?
      end
      self.completed if active?
      true
    rescue OodJobRails::JobHandler::Error
      false
    end

    # Update workflow status
    def update_status
      return true if completed?
      jobs.each do |job|
        job.update_status(status_job(job)) unless job.completed?
      end
      self.completed if jobs.all?(&:completed?)
      true
    rescue OodJobRails::JobHandler::Error
      false
    end

    # Set workflow to completed status
    def completed
      run_callbacks :completed do
        self.completed!
        self.passed!
      end
    end
  end
end
