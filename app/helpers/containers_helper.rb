module ContainersHelper

  # URL path helper
  def container_results_path(container, path)
    Pathname.new(files_path).join(container.staged_dir_relative_path, path).to_s
  end
end
