# http://robots.thoughtbot.com/prevent-spoofing-with-paperclip
# allow stl files to be uploaded
Paperclip.options[:content_type_mappings] = {
  :stl => "text/plain"
}

Paperclip::Attachment.default_options[:path] = "#{ENV['HOME']}/crimson_files/ContainerFillSim/uploads/:hash/:attachment/:filename"
Paperclip::Attachment.default_options[:url] = ":rails_relative_url_root/files/uploads/:hash/:attachment/:filename"
Paperclip::Attachment.default_options[:hash_data] = ":class/:id/:created_at"
Paperclip::Attachment.default_options[:hash_secret] = Rails.application.class.parent_name

Paperclip.interpolates :rails_relative_url_root do |attachment, style|
  Rails.application.config.action_controller.relative_url_root.to_s
end

Paperclip.interpolates :created_at do |attachment, style|
  attachment.instance.created_at
end
