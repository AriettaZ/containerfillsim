# This file is used by Rack-based servers to start the application.

# Remove these two lines when a proper method is put in place
# to pass these environment variables (e.g., the EPI)
ENV['RAILS_DATAROOT'] = "#{ENV['HOME']}/awesim/ContainerFillSim"
ENV['RAILS_DATABASE'] = "#{ENV['HOME']}/awesim/ContainerFillSim/db/production.sqlite3"

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
