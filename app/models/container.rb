class Container < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Submittable
  has_many :jobs, dependent: :destroy
  has_many :inlets, dependent: :destroy
  has_many :outlets, dependent: :destroy

  accepts_nested_attributes_for :inlets, allow_destroy: true
  accepts_nested_attributes_for :outlets, allow_destroy: true

  has_attached_file :walls
  do_not_validate_attachment_file_type :walls
  validates_presence_of :walls
  
  SOLVE_SCRIPT_NAME="main.sh"
  POST_SCRIPT_NAME="post.sh"
  
  MEASUREMENT_SCALES = {
    mm: "(0.001 0.001 0.001)",
    cm: "(0.01 0.01 0.01)",
    meters: "(1.0 1.0 1.0)",
    inches: "(0.254 0.254 0.254)"
  }
  
  # default to 5 steps
  def steps
    @steps || 5
  end

  def inlet_list
    inlets.to_a
  end

  def outlet_list
    outlets.to_a
  end

  def walls_name
    File.basename(self.walls_file_name, '.*')
  end
  
  def measurement_scale_name
    Container::MEASUREMENT_SCALES.invert[measurement_scale]
  end
  
  # FIXME: configuration by overriding methods is not as good
  # as configuration by custom objects
  def staging_script_name
    Container::SOLVE_SCRIPT_NAME
  end
  
  # FIXME: offer this functionality in machete itself!!!
  def stage
    # stage job and copy files
    job = staging.new_job self
    
    # copy files
    target = job.path.join("constant", "triSurface")
    
    self.inlets.each do |inlet|
      FileUtils.cp inlet.stl.path, target
    end
    self.outlets.each do |outlet|
      FileUtils.cp outlet.stl.path, target
    end
    FileUtils.cp walls.path, target
    
    job
  end
  
  #FIXME: in machete, if you don't check to see if respond_to? :pbsid 
  # you get an error if the migration never occurred for jobs:
  # undefined local variable or method `pbsid' for #<Container:0x007fe0f79c9700>
  # when after_find occurs
  
  #FIXME: in machete, offer a simpler database migration for adding these fields
  
  #FIXME: in machete, we should have stage and submit so we can
  # override stage and test it without submitting easily
  # And then use a StagingFactory to create one with default values
  # that we can override
  def submit
    _jobs = []
    
    # stage first job and add to array
    _jobs << stage
    jobdir = _jobs.first.path
    
    # create second job
    _jobs << OSC::Machete::Job.new(script: jobdir.join(Container::POST_SCRIPT_NAME)).afterok(_jobs.last)
    
    # submit all jobs
    _jobs.each(&:submit)
    
    # first save this container so you can use the id when creating the associated Jobs
    save if id.nil?
    
    # persist job data
    _jobs.each do |job|
      self.jobs.create(job: job)
    end
  end
  
  # status presenter methods
  # FIXME: should have a better solution for this
  def submitted?
    jobs.count > 0
  end

  def completed?
    # true if all jobs are completed
    submitted? && jobs.where(status: ["F", "C"]).count == jobs.count
  end

  def failed?
    # true if any of the jobs .failed?
    jobs.where(status: ["F"]).any?
  end

  # returns true if in a running state (R,Q,H)
  def running?
    # true if any of the jobs .running?
    jobs.where(status: ["Q", "R", "H"]).any?
  end

  # FIXME: better name for this?
  def status_human_readable
    if completed?
      "Completed"
    elsif jobs.where(status: "R").any?
      "Running"
    elsif jobs.where(status: "Q").any?
      "Queued"
    elsif jobs.where(status: "H").any?
      "Hold"
    else
      "Not Submitted"
    end
  end
 
  def job_dir_name
    Pathname.new(jobs.first.job_path).basename.to_s unless jobs.count == 0
  end 
  
  # copy all the files I specify to triSurface/
end
