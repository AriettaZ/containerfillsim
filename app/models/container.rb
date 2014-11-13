class Container < ActiveRecord::Base
  include OSC::Machete::SimpleJob
  
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
end
