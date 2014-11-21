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
    return solver_results_valid? if script_name == Container::SOLVE_SCRIPT_NAME
    return post_results_valid? if script_name == Container::POST_SCRIPT_NAME
    
    raise "No validation method for job with script: #{script_name}"
  end

  def solver_results_valid?
    # check LOG-iF
    # UNIT TESTS ARE GOOD FOR THIS
    true
  end

  def post_results_valid?
    # check for existence of images for each timestep
    # check for existence of filling.gif
    paths = (0..(container.steps)).map { |i| Pathname.new(job_path).join("images/t%.2d.png" % i) }
    paths << Pathname.new(job_path).join("movies/filling.gif")
    
    paths.all?(&:exist?)
  end
end
