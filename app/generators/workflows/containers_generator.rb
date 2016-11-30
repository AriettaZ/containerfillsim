module Workflows
  class ContainersGenerator < OodJobRails::Generators::WorkflowBase
    def copy_over_wall
      copy_file @model.wall.file_path, @model.root.join("wall", @model.wall.file.original_filename)
    end

    def copy_over_inlets
      @model.inlets.each do |inlet|
        copy_file inlet.file_path, @model.root.join("inlets", inlet.file.original_filename)
      end
    end

    def stage_container
      directory ".", @model.root
    end
  end
end
