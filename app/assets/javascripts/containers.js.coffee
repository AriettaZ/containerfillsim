# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

fluid_list = {}

fluid_list["water"] =
  viscosity: 0.000001
  density: 998.23

fluid_list["oil"] =
  viscosity: 0.00025
  density: 800

$ ->
  $('[data-toggle="tooltip"]').tooltip()

  # Add list of fluids to container form
  for key of fluid_list
    new_option = document.createElement("option")
    new_option.value = key
    document.querySelector("#fluid_list").appendChild(new_option)

  # Update viscosity/density for chosen fluid
  update_fluid = (event) ->
    key = event.target.value
    if key of fluid_list
      document.querySelector("#container_kinematic_viscosity").value = fluid_list[key].viscosity
      document.querySelector("#container_density").value = fluid_list[key].density
    return

  # Add event listener on fluid type input and update
  # viscosity/density accordingly
  document.querySelector("#container_fluid_type").addEventListener "input", update_fluid

  return
