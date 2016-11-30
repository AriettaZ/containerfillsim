class Container < OodJobRails::Workflow
  has_one :wall, foreign_key: "workflow_id", inverse_of: :container, dependent: :destroy
  has_many :inlets, foreign_key: "workflow_id", inverse_of: :container, dependent: :destroy

  store_accessor :jobs, :main, :post
  store_accessor :metadata, :name, :temperature, :success

  after_completed { |workflow| workflow.success = true; workflow.save }

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

  # Submit workflow
  def submit
    submit_wrapper do
      self.main = submit_job(cluster_id: "oakley", script: main_script)
      self.post = submit_job(cluster_id: "oakley", script: post_script, afterok: main[:id])
    end
  end
end
