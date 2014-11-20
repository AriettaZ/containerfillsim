class Job < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Statusable
  belongs_to :container

  before_destroy { |j| j.job.delete(rmdir: true) }
  
  def job
    OSC::Machete::Job.new(pbsid: pbsid, script: Pathname.new(job_path).join(script_name))
  end
end
