json.array!(@containers) do |container|
  json.extract! container, :name, :measurement, :fluid_type, :kinematic_viscosity, :density, :outlet_pressure, :inlet_vx, :inlet_vy, :inlet_vz
  json.url container_url(container, format: :json)
end
