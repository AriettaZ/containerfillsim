module OodJobRails
  # The Rails engine that defines the OodJobRails environment
  class Engine < Rails::Engine
    # Sets default configuration options before initializers are called
    config.before_initialize do
      OodJobRails.set_default_configuration
    end
  end
end
