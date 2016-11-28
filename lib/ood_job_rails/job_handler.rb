Adapter = OodJob::Adapters::Torque

require 'active_support/concern'

module OodJobRails
  module JobHandler
    extend ActiveSupport::Concern

    class Error < StandardError; end

    # Submit job for given cluster
    def submit_job(cluster:, script:, **kwargs)
      Dir.chdir(self.root) do
        Adapter.new(cluster: cluster).submit(script: OodJob::Script.new(script.to_h), **kwargs)
      end
    rescue OodJob::Adapter::Error => e
      msg = "An error occurred when submitting jobs for workflow (#{id}): #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error(msg)
      raise Error
    end

    # Delete job for given cluster
    def stop_job(cluster:, id:)
      Adapter.new(cluster: cluster).delete(id: id.to_s)
    rescue OodJob::Adapter::Error => e
      msg = "An error occurred when deleting jobs for workfow (#{id}): #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error(msg)
      raise Error
    end

    # Get status of job for given cluster
    def status_job(cluster:, id:)
      status = Adapter.new(cluster: cluster).status(id: id.to_s).to_sym
      (status == :undetermined) ? "completed" : status.to_s # assume if doesn't exist it is complete
    rescue OodJob::Adapter::Error => e
      msg = "An error occurred when retrieving the status of jobs for workflow (#{id}): #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error(msg)
      raise Error
    end
  end
end
