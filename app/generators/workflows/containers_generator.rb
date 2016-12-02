module Workflows
  class ContainersGenerator < OodJobRails::Generators::WorkflowBase
    def stage_container
      directory ".", model.root
    end

    def copy_over_wall
      empty_directory "wall"
      copy_file model.wall.file_path, "wall/#{model.wall.file.original_filename}"
    end

    def copy_over_inlets
      empty_directory "inlets"
      model.inlets.each do |inlet|
        copy_file inlet.file_path, "inlets/#{inlet.file.original_filename}"
      end
    end
  end
end
