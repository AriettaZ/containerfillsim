require "shrine"
require "shrine/storage/file_system"

class AttachmentUploader < Shrine
  def generate_location(io, context = {})
    dir  = generate_uid(io)
    name = extract_filename(io).to_s

    [dir, name].compact.join("/")
  end
end

AttachmentUploader.storages = {
  cache: Shrine::Storage::FileSystem.new(OodAppkit.dataroot.join("attachments").to_s, prefix: "cache"),
  store: Shrine::Storage::FileSystem.new(OodAppkit.dataroot.join("attachments").to_s, prefix: "store")
}

AttachmentUploader.plugin :activerecord
AttachmentUploader.plugin :cached_attachment_data
AttachmentUploader.plugin :download_endpoint, storages: [:store], prefix: [ENV['RAILS_RELATIVE_URL_ROOT'][1..-1], "attachments"]

# clear cache
AttachmentUploader.storages[:cache].clear!(older_than: Time.now - 3600) # delete files older than an hour
