class Container < ActiveRecord::Base
  has_many :jobs, dependent: :destroy
  has_machete_workflow_of :jobs

  has_many :inlets, dependent: :destroy, inverse_of: :container
  has_many :outlets, dependent: :destroy, inverse_of: :container

  accepts_nested_attributes_for :inlets, allow_destroy: true
  accepts_nested_attributes_for :outlets, allow_destroy: true

  validates :name, presence: true
  validates :measurement_scale, presence: true
  validates :fluid_type, presence: true
  validates :kinematic_viscosity, presence: true
  validates :density, presence: true

  has_attached_file :walls, validate_media_type: false
  do_not_validate_attachment_file_type :walls
  validates_presence_of :walls

  SOLVE_SCRIPT_NAME="main.sh"
  POST_SCRIPT_NAME="post.sh"

  MEASUREMENT_SCALES = {
    mm: "(0.001 0.001 0.001)",
    cm: "(0.01 0.01 0.01)",
    meters: "(1.0 1.0 1.0)",
    inches: "(0.0254 0.0254 0.0254)"
  }

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

  def after_stage(staged_dir)
    target = staged_dir.join("constant", "triSurface")

    self.inlets.each do |inlet|
      FileUtils.cp inlet.stl.path, target
    end
    self.outlets.each do |outlet|
      FileUtils.cp outlet.stl.path, target
    end
    FileUtils.cp walls.path, target
  end

  def build_jobs(staged_dir, jobs = [])
    # create solve_job and post_job Job objects, given the path to their scripts
    solve_job = OSC::Machete::Job.new(script: staged_dir.join(Container::SOLVE_SCRIPT_NAME))
    post_job = OSC::Machete::Job.new(script: staged_dir.join(Container::POST_SCRIPT_NAME))
    
    # setup dependency so post_job runs after solve_job completes
    post_job.afterany(solve_job)

    # add them to the array and return the array 
    jobs << solve_job
    jobs << post_job
  end



  def copy
    new_container = self.dup
    new_container.name = "Copy of #{self.name}"
    new_container.walls = self.walls

    self.inlets.each do |inlet|
      new_container.inlets << inlet.dup
      new_container.inlets.last.stl = inlet.stl
    end
    self.outlets.each do |outlet|
      new_container.outlets << outlet.dup
      new_container.outlets.last.stl = outlet.stl
    end

    new_container
  end

  def job_dir_name
    Pathname.new(staged_dir).basename.to_s
  end

  # copy all the files I specify to triSurface/
end
