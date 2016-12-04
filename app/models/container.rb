class Container < OodJobRails::Workflow
  # Attachments
  has_one :wall, foreign_key: :workflow_id, inverse_of: :container, dependent: :destroy
  has_many :inlets, foreign_key: :workflow_id, inverse_of: :container, dependent: :destroy
  accepts_nested_attributes_for :wall
  accepts_nested_attributes_for :inlets, allow_destroy: true

  # Jobs
  has_one :main_job, foreign_key: :workflow_id, inverse_of: :container
  has_one :post_job, foreign_key: :workflow_id, inverse_of: :container

  # Metadata
  store_accessor :metadata, :name, :temperature, :success
  validates :name, presence: true
  validates :temperature, presence: true
  validates :temperature, numericality: true

  after_completed { |workflow| workflow.failed! }

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

  def stage
    Workflows::ContainersGenerator.new(self).invoke_all
  end

  # Submit workflow
  def submit
    submit_wrapper do
      build_main_job(submit_job(cluster_id: "oakley", script: main_script))
      build_post_job(submit_job(cluster_id: "oakley", script: post_script, afterok: main_job.job_id))
    end
  end
end
