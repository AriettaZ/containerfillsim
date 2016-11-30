module OodJobRails
  class Workflow < ActiveRecord::Base
    include JobHandler

    enum status: [ :not_submitted, :active, :completed ]

    store :jobs,     accessors: [], coder: JSON
    store :metadata, accessors: [], coder: JSON

    after_commit :set_root, on: :create
    before_destroy :clean_up_jobs
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
      stage
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
      jobs.each do |name, job|
        stop_job(job)
      end
      self.completed if active?
      true
    rescue OodJobRails::JobHandler::Error
      false
    end

    # Update workflow status
    def update_status
      return true if completed?
      jobs.each do |name, job|
        job[:status] = status_job(job)
      end
      self.save

      # Update status of workflow if all jobs complete
      self.completed if jobs.all? { |name, job| job[:status] == "completed" }
      true
    rescue OodJobRails::JobHandler::Error
      false
    end

    # Set workflow to completed status
    def completed
      run_callbacks :completed do
        self.completed!
      end
    end
  end
end
