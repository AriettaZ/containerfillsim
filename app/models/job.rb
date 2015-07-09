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

  # return string "3950166" whether the pbsid
  # is "3950166" or "3960166.oak-batch.osc.edu"
  def pbsid_number
    pbsid =~ /(\d+)(\..*)?/
    $1
  end

  # FIXME: a useful method for any file relative to the job dir path?
  # FIXME: a null path object would be useful so
  # calling read on it doesn't throw an error
  def output_file_path
    path = Pathname.new(job_path).join("*.o#{pbsid_number}")
    Pathname.glob(path).first # || Pathname.new("")
  end

  def error_file_path
    path = Pathname.new(job_path).join("*.e#{pbsid_number}")
    Pathname.glob(path).first
  end

  def output_file_contents
    path = output_file_path
    path ? path.read : ""
  end

  def error_file_contents
    path = error_file_path
    path ? path.read : ""
  end

  # timesteps value should not be off from the request steps
  # by more than 0.001
  def main_results_valid?
    (container.steps - final_timestep_for_log).abs <= 0.001
  end

  # the LOG-iF file contains lines in the form:
  # Time = 4.99853
  # Time = 4.99902
  #
  # returns the final timestemp value in the file, or 0.0 if non available
  def final_timestep_for_log
    path = Pathname.new(self.job_path).join("LOG-iF")
    timestep=0.0

    if path.exist? && path.readable?
      path.each_line do |line|
        # iterate through each line in order; assume final match is the largest
        if /^Time = (\d+(\.\d+)?)$/.match(line)
          timestep = $1.to_f # $1 matches the first parens which is the number
        end
      end
    end

    timestep
  end

  def post_results_valid?
    # check for existence of images for each timestep
    # check for existence of filling.gif
    paths = (0..(container.steps)).map { |i| Pathname.new(job_path).join("images/t%.2d.png" % i) }
    paths << Pathname.new(job_path).join("movies/filling.gif")

    paths.all?(&:exist?)
  end
end
