class Attachment < ActiveRecord::Base
  store :metadata, accessors: [], coder: JSON

  include AttachmentUploader[:file]
  validates :file, presence: true
end
