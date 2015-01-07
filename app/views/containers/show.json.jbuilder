json.extract! @container, :name, :measurement_scale, :fluid_type, :kinematic_viscosity, :density, :steps, :walls_file_name, :created_at, :updated_at
json.inlets @container.inlets do |inlet|
  json.extract! inlet, :stl_file_name, :vx, :vy, :vz
end
json.outlets @container.outlets do |outlet|
  json.extract! outlet, :stl_file_name
end
