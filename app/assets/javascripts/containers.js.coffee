# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@FluidLister =
  fluid_list:
    water:
      viscosity: 0.000001
      density: 998.23
    oil:
      viscosity: 0.00025
      density: 800
    honey:
      viscosity: 0.0000736
      density: 1420
    beer:
      viscosity: 0.0000018
      density: 1010
    milk:
      viscosity: 0.00000113
      density: 1035
    mercury:
      viscosity: 0.000000118
      density: 13590

  # Create list of fluids as options to choose
  setup: ->
    for key of @fluid_list
      $("#fluid_list").append($('<option>').val(key))

  update: ->
    fluid = $("#container_fluid_type").val()
    if fluid of @fluid_list
      $("#container_kinematic_viscosity").val @fluid_list[fluid].viscosity
      $("#container_density").val @fluid_list[fluid].density

$ ->
  # Must opt-in to use Bootstrap tooltips
  $('[data-toggle="tooltip"]').tooltip container: "body"

  # Only allow user to click "Launch Paraview" button once
  $('#paraviewBtn').on 'click', ->
    $(this).button('loading')
    return

  # List fluids when making new container
  if $("#fluid_list").length > 0
    FluidLister.setup()

  # Update viscosity/density when fluid is changed
  $("#container_fluid_type").on 'input', (e) ->
    FluidLister.update()

  # Load polyfills if browser doesn't have datalist
  Modernizr.load
    test: Modernizr.datalistelem
    nope: [
      '/awesim_dev/rails9/assets/polyfill/jquery.datalist.js'
      '/awesim_dev/rails9/assets/polyfill/load.datalist.js'
    ]

  return
