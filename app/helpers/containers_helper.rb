module ContainersHelper
  def job_status_label(sim)
    label_class = "label-default"
    
    if sim.failed?
      label_class = "label-danger"
    elsif sim.completed?
      label_class = "label-success"
    elsif sim.running?
      label_class = "label-primary"
    end
    
    "<span class=\"label #{label_class}\">#{sim.status_human_readable}</span>".html_safe
  end
end
