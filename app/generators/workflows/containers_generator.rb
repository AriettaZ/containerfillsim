module Workflows
  class ContainersGenerator < Rails::Generators::Base
    def self.default_source_root
      Rails.root.join('templates', generator_name)
    end

    def self.desc(description = nil)
      return super if description

      @desc ||= if usage_path
                  ERB.new(File.read(usage_path)).result(binding)
                else
                  "Description:\n    Stages files for the #{generator_name} workflow."
                end
    end

    argument :model_id, type: :string

    def initialize(*args)
      super
      self.destination_root = model.root
    end

    no_tasks do
      def model
        @model ||= self.class.generator_name.classify.constantize.find model_id
      end
    end

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
