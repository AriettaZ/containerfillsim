json.array!(@containers) do |container|
  json.extract! container, :name, :measurement_scale, :fluid_type, :kinematic_viscosity, :density
  json.url container_url(container, format: :json)
end
