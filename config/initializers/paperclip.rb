# http://robots.thoughtbot.com/prevent-spoofing-with-paperclip
# allow stl files to be uploaded
Paperclip.options[:content_type_mappings] = {
  :stl => "text/plain"
}

Paperclip::Attachment.default_options[:path] = "#{ENV['HOME']}/crimson_files/ContainerFillSim/uploads/:id/:attachment/:filename"
Paperclip::Attachment.default_options[:url] = ":rails_relative_url_root/files/uploads/:id/:attachment/:filename"

Paperclip.interpolates :rails_relative_url_root do |attachment, style|
  Rails.application.config.action_controller.relative_url_root.to_s
end
