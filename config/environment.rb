# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Set the Rails data root path
ENV["RAILS_DATAROOT"] ||= OSC::Machete::Crimson.new(Rails.application.class.parent_name).files_path.to_s

# Initialize the Rails application.
ContainerFillSim::Application.initialize!
