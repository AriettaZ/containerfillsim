module OodJobRails
  class Attachment < ActiveRecord::Base
    store :metadata, accessors: [], coder: JSON

    include Uploader[:file]
    validates :file, presence: true

    # Get path to file on local filesystem
    def file_path
      file.storage.directory.join(file.id)
    end
  end
end
