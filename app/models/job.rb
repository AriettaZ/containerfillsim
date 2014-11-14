class Job < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Statusable
  belongs_to :container
end
