require 'ood_job_rails'

module Workflows
  class ContainerGenerator < OodJobRails::Generators::WorkflowBase
    def stage_container
      directory ".", @model.root
    end
  end
end
