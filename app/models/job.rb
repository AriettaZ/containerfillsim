class Job < ActiveRecord::Base
  include OscMacheteRails::Statusable
  belongs_to :container

  # return string "3950166" whether the is "3950166" or "3960166.oak-batch.osc.edu"
  def pbsid_number
    pbsid =~ /(\d+)(\..*)?/
    $1
  end

  # this job dir is in format DATAROOT/containers/12
  # so to get "containers/12" we can do this
  # its safe to use relative_path_from only with the same path
  # because if you use it with the DATAROOT we could be dealing with
  # symlinks which can cause issues
  # i.e. job_path is /nfs/17/efranz... and DATAROOT is /users/PZXXX/efranz...
  def job_dir_relative_path
    p = Pathname.new(job_path)
    p.relative_path_from(p.parent.parent)
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
    f = output_file_path
    job_dir_relative_path.join(output_file_path.basename) if f
  end

  # path relative to dataroot
  def error_file_relative_path
    f = error_file_path
    job_dir_relative_path.join(error_file_path.basename) if f
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
