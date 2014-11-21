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
  
  def results_valid?
    # FIXME: magic strings here and in Container.rb!!!
    return solver_results_valid? if script_name == "runScript.txt"
    return post_results_valid? if script_name == "gpuRenderScript.txt"
    
    raise "No validation method for job with script: #{script_name}"
  end

  def solver_results_valid?
    # check LOG-iF
    # UNIT TESTS ARE GOOD FOR THIS
    true
  end

  def post_results_valid?
    # check for existence of images for each timestep
    # (list of Pathname objects).all(exist?)
    # check for existence of filling.gif
    #
    # problem with this approach is that to validate the job, we need
    # the container (or the container's template_presenter) to access
    # the steps attr
    #
    # paths = (0..steps).map { |i| Pathname.new("images/%.2d" % i) }
    # paths << Pathname.new("movies/filling.gif")
    # paths.all?(&:exist?)
    true
  end
end
