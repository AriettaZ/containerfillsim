class MigrateContainerAttachmentData < ActiveRecord::Migration
  # define classes to help with data migration
  class Inlet < ActiveRecord::Base
    belongs_to :container
  end
  class Outlet < ActiveRecord::Base
    belongs_to :container
  end
  class Container < ActiveRecord::Base
    has_many :inlets
    has_many :outlets
  end

  def self.up
    # create new attachments
    Container.all.each do |c|
      c.inlets.create(
        stl_file_name: c.inlet_file_name,
        stl_content_type: c.inlet_content_type,
        stl_file_size: c.inlet_file_size,
        stl_updated_at: c.inlet_updated_at,
        vx: c.inlet_vx, vy: c.inlet_vy, vz: c.inlet_vz)
      c.outlets.create(
        stl_file_name: c.outlet_file_name,
        stl_content_type: c.outlet_content_type,
        stl_file_size: c.outlet_file_size,
        stl_updated_at: c.outlet_updated_at,
        pressure: c.outlet_pressure)
    end
  end

  def self.down
    # we could copy back if we wanted it to be bullet proof
    Container.all.each do |c|
      c.inlets.delete_all
      c.outlets.delete_all
    end
  end
end
