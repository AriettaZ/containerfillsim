require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  setup do
    container = Container.new(name: "test",
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
  end
  
  test "staging copies input files" do
  end
  
  test "staging" do
  end
end
