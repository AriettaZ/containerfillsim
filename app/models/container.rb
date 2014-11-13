class Container < ActiveRecord::Base
  include OSC::Machete::SimpleJob
  
  [:inlet, :outlet, :walls].each do |f|
    has_attached_file f
    do_not_validate_attachment_file_type f
    validates_presence_of f
  end
end
