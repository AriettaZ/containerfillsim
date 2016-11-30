require 'rails/generators'

module OodJobRails
  module Generators
    class WorkflowBase < Rails::Generators::Base
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

      no_tasks do
        def model
          @model ||= self.class.generator_name.classify.constantize.find model_id
        end
      end
    end
  end
end
