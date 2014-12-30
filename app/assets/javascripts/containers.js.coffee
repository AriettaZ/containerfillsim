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

fluid_list["honey"] =
  viscosity: 0.0000736
  density: 1420

fluid_list["beer"] =
  viscosity: 0.0000018
  density: 1010

fluid_list["milk"] =
  viscosity: 0.00000113
  density: 1035

fluid_list["mercury"] =
  viscosity: 0.000000118
  density: 13590

$ ->
  $('[data-toggle="tooltip"]').tooltip()

  # Only allow user to click "Launch Paraview" button once
  $('#paraviewBtn').on 'click', ->
    $(this).button('loading')
    return

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
