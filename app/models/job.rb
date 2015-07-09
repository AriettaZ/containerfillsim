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

  # return string "3950166" whether the is "3950166" or "3960166.oak-batch.osc.edu"
  def pbsid_number
    pbsid =~ /(\d+)(\..*)?/
    $1
  end

  # return first path found for the given filename/path or glob pattern relative
  # to the job's directory
  def job_file_path(file)
    Pathname.glob("#{job_path}/#{file}").first
  end

  def output_file_path
    job_file_path "*.o#{pbsid_number}"
  end

  def error_file_path
    job_file_path "*.e#{pbsid_number}"
  end

  # path relative to dataroot
  def output_file_relative_path
    output_file_path.relative_path_from(AwesimRails.dataroot) if output_file_path
  end

  # path relative to dataroot
  def error_file_relative_path
    error_file_path.relative_path_from(AwesimRails.dataroot) if error_file_path
  end

  def output_file_contents
    output_file_path ? output_file_path.read : ""
  end

  def error_file_contents
    error_file_path ? error_file_path.read : ""
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
