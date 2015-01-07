require 'test_helper'

class JobTest < ActiveSupport::TestCase
  setup do
    @container = Container.create(name: "test",
      measurement_scale: Container::MEASUREMENT_SCALES[:meters],
      fluid_type: "water",
      kinematic_viscosity: 0.000001,
      density: 998.23,
      walls: File.new("test/fixtures/control/constant/triSurface/walls.stl"),
    )

    @container.inlets.create(stl: File.new("test/fixtures/control/constant/triSurface/inlet1.stl"), vx: 0, vy: -1, vz: 0)
    @container.outlets.create(stl: File.new("test/fixtures/control/constant/triSurface/outlet1.stl"))
  end

  def setup_jobs_for_control(path)
    @container.jobs.create(
      pbsid: "123456.oak-batch.osc.edu",
      status: "C",
      job_path: path,
      script_name: Container::SOLVE_SCRIPT_NAME # FIXME: duplication in three places?
    )
    @container.jobs.create(
      pbsid: "123457.oak-batch.osc.edu",
      status: "C",
      job_path: path,
      script_name: Container::POST_SCRIPT_NAME # FIXME: duplication in three places?
    )
  end

  test "validate successful simulation" do
    setup_jobs_for_control("test/fixtures/control_success")

    assert @container.jobs.first.results_valid?
    assert @container.jobs.last.results_valid?, "post is valid because all images exist, but results_valid? returned false"
  end

  test "validate failed simulation" do
    setup_jobs_for_control("test/fixtures/control_fail")

    assert ! @container.jobs.first.results_valid?, "solver is invalid because of LOG-iF missing steps, but this validation returned true"
    assert ! @container.jobs.last.results_valid?, "post is invalid because of missing images, but this validation returned true"
  end
end
