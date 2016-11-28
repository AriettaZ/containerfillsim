class Attachment < ActiveRecord::Base
  store :extend, accessors: [], coder: JSON

  attachment :file

  validates :file, presence: true
end
