module Workflows
  class ContainersGenerator < OodJobRails::Generators::WorkflowBase
    def stage_container
      directory ".", @model.root
    end
  end
end
