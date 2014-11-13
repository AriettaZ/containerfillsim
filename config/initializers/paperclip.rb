# http://robots.thoughtbot.com/prevent-spoofing-with-paperclip
# allow stl files to be uploaded
Paperclip.options[:content_type_mappings] = {
  :stl => "text/plain"
}

Paperclip::Attachment.default_options[:path] = "#{ENV['HOME']}/crimson_files/ContainerFillSim/uploads/:id/:attachment/:basename.:extension"

