class Attachment < ActiveRecord::Base
  store :extend, accessors: [], coder: JSON

  # attachment :file
  include AttachmentUploader[:file]

  validates :file, presence: true
end
