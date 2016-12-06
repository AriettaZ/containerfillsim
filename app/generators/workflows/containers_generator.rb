module Workflows
  class ContainersGenerator < Thor::Group
    include Thor::Actions

    argument :model
    source_root Rails.root.join('templates', 'containers')

    def initialize(*)
      super
      self.destination_root = model.root
    end

    def stage_container
      directory "."
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
