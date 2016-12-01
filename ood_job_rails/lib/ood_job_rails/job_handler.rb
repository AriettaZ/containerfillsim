require 'ood_job'
require 'active_support/concern'

module OodJobRails
  module JobHandler
    extend ActiveSupport::Concern

    class Error < StandardError; end

    def default_job_script
      OodJobRails.default_job_script.to_h.merge(
        workdir: self.root
      )
    end

    # Submit job for given cluster
    def submit_job(cluster_id:, script:, after: [], afterok: [], afternotok: [], afterany: [], **_)
      script = OodJob::Script.new(default_job_script.merge(script.to_h))
      job_id = OodJobRails.adapter.new(cluster: OodJobRails.clusters[cluster_id.to_sym]).submit(
        script:     script,
        after:      [after     ].flatten.map(&:to_s),
        afterok:    [afterok   ].flatten.map(&:to_s),
        afternotok: [afternotok].flatten.map(&:to_s),
        afterany:   [afterany  ].flatten.map(&:to_s)
      )
      { job_id: job_id, cluster_id: cluster_id }
    rescue OodJob::Adapter::Error => e
      msg = "An error occurred when submitting jobs for workflow (#{self.id}): #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error(msg)
      raise Error
    end

    # Delete job for given cluster
    def stop_job(job)
      job_id       = job.respond_to?(:job_id)     ? job.job_id     : job[:job_id]
      cluster_id   = job.respond_to?(:cluster_id) ? job.cluster_id : job[:cluster_id]
      return true if job_id.nil? || cluster_id.nil?
      OodJobRails.adapter.new(cluster: OodJobRails.clusters[cluster_id.to_sym]).delete(id: job_id.to_s)
      job.stopped if job.respond_to?(:stopped)
    rescue OodJob::Adapter::Error => e
      msg = "An error occurred when deleting jobs for workfow (#{self.id}): #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error(msg)
      raise Error
    end

    # Get status of job for given cluster
    def status_job(job)
      job_id       = job.respond_to?(:job_id)     ? job.job_id     : job[:job_id]
      cluster_id   = job.respond_to?(:cluster_id) ? job.cluster_id : job[:cluster_id]
      return nil if job_id.nil? || cluster_id.nil?
      status = OodJobRails.adapter.new(cluster: OodJobRails.clusters[cluster_id.to_sym]).status(id: job_id.to_s).to_sym
      (status == :undetermined) ? "completed" : status.to_s # assume if doesn't exist it is complete
    rescue OodJob::Adapter::Error => e
      msg = "An error occurred when retrieving the status of jobs for workflow (#{self.id}): #{e.message}"
      errors.add(:base, msg)
      Rails.logger.error(msg)
      raise Error
    end
  end
end
