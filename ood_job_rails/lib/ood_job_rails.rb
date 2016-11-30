require_relative 'ood_job_rails/configuration'
require_relative 'ood_job_rails/job_handler'
require_relative 'ood_job_rails/workflow'
require_relative 'ood_job_rails/engine'

module OodJobRails
  extend Configuration

  module Generators
    require_relative 'ood_job_rails/generators/workflow_base'
  end
end
