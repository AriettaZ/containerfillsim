class Inlet < ActiveRecord::Base
  belongs_to :container, inverse_of: :inlets

  validates :vx, presence: true
  validates :vy, presence: true
  validates :vz, presence: true
  validates_presence_of :container

  has_attached_file :stl
  do_not_validate_attachment_file_type :stl
  validates_presence_of :stl

  def name
    File.basename(self.stl_file_name, '.*')
  end
end
