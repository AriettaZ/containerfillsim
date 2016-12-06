require 'shrine'
require 'shrine/storage/file_system'

module OodJobRails
  class Uploader < Shrine
    def self.storages
      OodJobRails.storages
    end
    plugin :activerecord
    plugin :cached_attachment_data
    plugin :download_endpoint, storages: [:store], prefix: [ENV['RAILS_RELATIVE_URL_ROOT'][1..-1], "attachments"]
    plugin :moving

    def generate_location(io, context = {})
      dir  = generate_uid(io)
      name = extract_filename(io).to_s

      [dir, name].compact.join("/")
    end
  end
end
