class Outlet < ActiveRecord::Base
  belongs_to :container, inverse_of: :outlets

  validates_presence_of :container

  has_attached_file :stl, validate_media_type: false
  do_not_validate_attachment_file_type :stl
  validates_presence_of :stl

  def name
    File.basename(self.stl_file_name, '.*')
  end
end
