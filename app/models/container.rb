class Container < ActiveRecord::Base
  [:inlet, :outlet, :walls].each do |f|
    has_attached_file f, path: "#{ENV['HOME']}/crimson_files/ContainerFillSim/uploads/:id/#{f}"
    validates_attachment_content_type f, :content_type => /text/
    validates_attachment_file_name f, :matches => [/stl\Z/]
    validates_presence_of f
  end
end
