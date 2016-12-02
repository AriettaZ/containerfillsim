require 'test_helper'
require 'tmpdir'

class ContainerTest < ActiveSupport::TestCase
  setup do
    @orig_dataroot = OodJobRails.dataroot
    OodJobRails.dataroot = Pathname.new(Dir.mktmpdir)
    @container = Container.create(name: "test", temperature: 25)
  end

  teardown do
    OodJobRails.dataroot.rmtree
    OodJobRails.dataroot = @orig_dataroot
  end

  test "container created" do
    refute_nil @container, "Container cannot be nil"
    assert_equal 25, @container.temperature
  end

  test "container root is based on id and created_atcontainer root auto builds when querying" do
    refute_nil @container.root, "@container.root returned nil"
    assert_equal OodJobRails.dataroot.join("containers"), @container.root.parent, "container must be created in containers directory"
    assert_equal "1_#{@container.created_at.to_i}", @container.root.basename.to_s, "first container's name must be 1_\#{created_at}"
  end
end
