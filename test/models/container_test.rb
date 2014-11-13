require 'test_helper'
require 'tmpdir'

class ContainerTest < ActiveSupport::TestCase
  
  setup do
    @container = Container.create(name: "test",
      measurement: "meters",
      fluid_type: "water",
      kinematic_viscosity: 0.000001,
      density: 998.23,
      outlet_pressure: 101325,
      inlet_vx: 0,
      inlet_vy: -1,
      inlet_vz: 0,
      inlet: File.new("test/fixtures/control/constant/triSurface/inlet1.stl"),
      outlet: File.new("test/fixtures/control/constant/triSurface/outlet1.stl"),
      walls: File.new("test/fixtures/control/constant/triSurface/walls.stl"),
    )
    
    # we render instances of simulations in tmpdir for testing purposes
    @target = Dir.mktmpdir
    
    # the container gives the staging object used
    @staging = @container.staging
    @staging.instance_variable_set(:@target, Pathname.new(@target).cleanpath)
    
    # the control is what we want to generate
    @expected = 'test/fixtures/control'
  end
  
  teardown do
    FileUtils.remove_entry @target
  end
  
  test "paperclip file set works" do
    assert_equal "inlet1.stl", @container.inlet_file_name
    assert_equal "outlet1.stl", @container.outlet_file_name
    assert_equal "walls.stl", @container.walls_file_name
  end
  
  test "staging copies input files" do
  end
  
  test "staging" do
    job = @staging.new_job(@container.serializable_hash)
    
    assert_equal "", `diff -rq #{job.path} #{@expected}`
  end
end
