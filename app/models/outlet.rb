class Outlet < ActiveRecord::Base
  belongs_to :container

  has_attached_file :stl
  do_not_validate_attachment_file_type :stl
  validates_presence_of :stl
end
