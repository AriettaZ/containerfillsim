class Inlet < OodJobRails::Attachment
  belongs_to :container, foreign_key: :ood_job_rails_workflow_id, inverse_of: :inlets

  store_accessor :metadata, :vx, :vy, :vz

  validates :vx, :vy, :vz, presence: true
  validates :vx, :vy, :vz, numericality: true
end
