class Inlet < Attachment
  belongs_to :container

  store_accessor :extend, :vx, :vy, :vz

  validates :vx, :vy, :vz, presence: true
  validates :vx, :vy, :vz, numericality: true
end
