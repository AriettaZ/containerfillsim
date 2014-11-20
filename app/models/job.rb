class Job < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Statusable
  belongs_to :container

  before_destroy { |j| j.job.delete(rmdir: true) }

  # Returns associated OSC::Machete::Job instance
  def job
    OSC::Machete::Job.new(pbsid: pbsid, script: Pathname.new(job_path).join(script_name))
  end

  # Setter that accepts an OSC::Machete::Job instance
  def job=(new_job)
    self.pbsid = new_job.pbsid
    self.job_path = new_job.path.to_s 
    self.script_name = new_job.script_name
    self.status = new_job.status
  end
end
