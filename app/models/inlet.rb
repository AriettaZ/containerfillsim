class Inlet < Attachment
  belongs_to :container, inverse_of: :inlets

  store_accessor :extend, :vx, :vy, :vz

  validates :vx, :vy, :vz, presence: true
  validates :vx, :vy, :vz, numericality: true
end
