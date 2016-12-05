module OodJobRails
  class Workflow < ActiveRecord::Base
    include JobHandler

    has_many :jobs, inverse_of: :workflow, dependent: :destroy

    enum status: [ :not_submitted, :active, :completed ]
    enum result: [ :no_result, :passed, :failed ]

    store :metadata, accessors: [], coder: JSON

    after_commit :set_root, on: :create
    before_destroy :clean_up_jobs, prepend: true    # run this before destroying jobs
    after_destroy :clean_up_files

    define_model_callbacks :completed

    def root
      if super
        path = OodJobRails.dataroot.join(super)
        path.mkpath # make root path if doesn't exist
        path
      end
    end

    def set_root
      # avoid infinite callback
      update_column :root, File.join(self.class.name.tableize, "#{id}_#{Time.now.to_i}")
    end

    def clean_up_jobs
      stop
    end

    def clean_up_files
      root.rmtree
    end

    # Stage workflow
    def stage
      "Workflows::#{self.class.name.pluralize}Generator".constantize.new([self.id]).invoke_all
    end

    # Submit workflow
    def submit_wrapper
      yield
      self.active!
      true
    rescue OodJobRails::JobHandler::Error
      self.stop
      false
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
