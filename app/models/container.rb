class Container < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Submittable
  has_many :jobs, dependent: destroy
  
  MEASUREMENT_SCALES = {
    mm: "(0.001 0.001 0.001)",
    cm: "(0.01 0.01 0.01)",
    meters: "(1.0 1.0 1.0)",
    inches: "(0.254 0.254 0.254)"
  }
  
  FLUID_TYPES = [:water, :oil]
  
  [:inlet, :outlet, :walls].each do |f|
    has_attached_file f
    do_not_validate_attachment_file_type f
    validates_presence_of f
  end
  
  #FIXME: move to a presenter or a view object to use with rendering
  #FIXME: are these supposed to be integers?
  # if so, why do we accept floats as arguments? or do we?
  def inlet_vx_i
    inlet_vx.round(0).to_s
  end
  def inlet_vy_i
    inlet_vy.round(0).to_s
  end
  def inlet_vz_i
    inlet_vz.round(0).to_s
  end
  
  # FIXME: configuration by overriding methods is not as good
  # as configuration by custom objects
  # 
  # FIXME: change job template so runScript.txt is main.sh
  # and gpuRenderScript.txt is post.sh
  def staging_script_name
    "runScript.txt"
  end
  
  # FIXME: offer this functionality in machete itself!!!
  def stage
    # stage job and copy files
    job = staging.new_job self
    
    # copy files
    target = job.path.join("constant/triSurface")
    
    FileUtils.cp inlet.path, target
    FileUtils.cp outlet.path, target
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
    job << stage
    jobdir = jobs.first.path
    
    # create second job
    _jobs << OSC::Machete::Job.new(script: jobdir.join("gpuRenderScript.txt")).afterok(_jobs.last)
    
    # submit all jobs
    _jobs.each(&:submit)
    
    # first save this container so you can use the id when creating the associated Jobs
    save if id.nil?
    
    # persist job data
    _jobs.each do |job|
      # FIXME: instead of storing the job directory path we should store the script path
      self.jobs.create(status: job.status, pbsid: job.pbsid, job_path: job.path.to_s, script_name: job.script_name)
    end
  end
  
  # status presenter methods
  # FIXME: should have a better solution for this
  def submitted?
    jobs.count > 0
  end

  def completed?
    # true if each of the jobs .completed?
    false
  end

  def failed?
    # true if any of the jobs .failed?
    false
  end

  # returns true if in a running state (R,Q,H)
  def running?
    # true if any of the jobs .running?
    false
  end

  # FIXME: better name for this?
  def status_human_readable
    "Not Submitted"
  end
  
  
  # copy all the files I specify to triSurface/
end
