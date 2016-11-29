class Container < Workflow
  has_one :wall, foreign_key: "workflow_id", inverse_of: :container, dependent: :destroy
  has_many :inlets, foreign_key: "workflow_id", inverse_of: :container, dependent: :destroy

  store_accessor :jobs, :main, :post
  store_accessor :extend, :name, :temperature

  validates :name, presence: true
  validates :temperature, presence: true

  validates :temperature, numericality: true

  accepts_nested_attributes_for :wall
  accepts_nested_attributes_for :inlets, allow_destroy: true

  def main_script
    {
      content: root.join("main.sh")
    }
  end

  def post_script
    {
      content: root.join("post.sh")
    }
  end

  # Setup workflow
  def stage
    Workflows::ContainerGenerator.new([self.id]).invoke_all
  end

  # Submit workflow
  def submit
    stage

    self.main = {
      id: submit_job(
        cluster: cluster("oakley"),
        script: main_script
      ),
      cluster: "oakley"
    }

    self.post = {
      id: submit_job(
        cluster: cluster("oakley"),
        script: post_script
      ),
      cluster: "oakley"
    }

    self.active!
    true
  rescue OodJobRails::JobHandler::Error
    self.stop
    false
  end

  # Stop workflow
  def stop
    return true if completed?
    stop_job(cluster: cluster(main[:cluster]), id: main[:id]) if main && main[:id]
    stop_job(cluster: cluster(post[:cluster]), id: post[:id]) if post && post[:id]
    true
  rescue OodJobRails::JobHandler::Error
    false
  end

  # Update workflow status
  def update_status
    return true if completed?
    self.main[:status] = status_job(cluster: cluster(main[:cluster]), id: main[:id]) if main && main[:id]
    self.post[:status] = status_job(cluster: cluster(post[:cluster]), id: post[:id]) if post && post[:id]
    self.save

    # Update status of workflow if all jobs complete
    self.complete! if main[:status] == "completed" && post[:status] == "completed"
    true
  rescue OodJobRails::JobHandler::Error
    false
  end
end
