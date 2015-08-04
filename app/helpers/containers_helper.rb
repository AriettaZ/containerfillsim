module ContainersHelper

  # URL path helper
  def container_results_path(container, path)
    Pathname.new(files_path).join(container.staged_dir_relative_path, path).to_s
  end

  def job_status_label(job)
    label_class = "label-default"
    status = "Not Submitted"    

    if job
      status = job.status_human_readable
      
      if job.failed?
        label_class = "label-danger"
      elsif job.completed?
        label_class = "label-success"
      elsif job.active?
        label_class = "label-primary"
      end
    end
    
    "<span class=\"label #{label_class}\">#{status}</span>".html_safe
  end
end
