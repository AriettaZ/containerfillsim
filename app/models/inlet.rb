class Inlet < Attachment
  belongs_to :container, foreign_key: :workflow_id, inverse_of: :inlets

  store_accessor :metadata, :vx, :vy, :vz

  validates :vx, :vy, :vz, presence: true
  validates :vx, :vy, :vz, numericality: true
end
