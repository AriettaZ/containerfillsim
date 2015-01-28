require 'test_helper'
require 'tmpdir'

class ContainerTest < ActiveSupport::TestCase

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

    # we render instances of simulations in tmpdir for testing purposes
    @target = Dir.mktmpdir
    
    # how do we stub where the 
    @container.stubs(:staging_target_dir).returns(Pathname.new(@target).cleanpath)

    # the control is what we want to generate
    @expected = 'test/fixtures/control'
  end

  teardown do
    FileUtils.remove_entry @target
  end

  test "paperclip file set works" do
    assert_equal "inlet1.stl", @container.inlets.first.stl_file_name
    assert_equal "outlet1.stl", @container.outlets.first.stl_file_name
    assert_equal "walls.stl", @container.walls_file_name
  end

  test "staging copies input files" do
  end

  test "staging" do
    # now if we test staging, it is separated into three parts
    # because we switched to using OSC::Machete::SimpleJob::Workflow
    jobpath = @container.stage
    @container.render_mustache_files(jobpath, @container)
    @container.after_stage(jobpath)
    
    assert_equal "", `diff -r #{jobpath}/0_orig #{@expected}/0_orig`
    assert_equal "", `diff -r #{jobpath}/system/controlDict #{@expected}/system/controlDict`, "system/controlDict render failed"
    assert_equal "", `diff -r #{jobpath}/main.sh #{@expected}/main.sh`, "main.sh render failed"
    # assert_equal "", `diff -r #{job.path}/image.py #{@expected}/image.py`, "image.py render failed"
    assert_equal "", `diff -r #{jobpath}/constant/transportProperties #{@expected}/constant/transportProperties`
    # assert_equal "", `diff -rq #{job.path} #{@expected}`

    assert_equal "", `diff -rq #{jobpath}/constant/triSurface #{@expected}/constant/triSurface`, "input files not copied to constant/triSurface/"
  end
end
