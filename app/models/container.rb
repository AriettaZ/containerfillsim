class Container < ActiveRecord::Base
  [:inlet, :outlet, :walls].each do |f|
    has_attached_file f
    validates_attachment_content_type f, :content_type => /text/
    validates_attachment_file_name f, :matches => [/stl\Z/]
  end
end
