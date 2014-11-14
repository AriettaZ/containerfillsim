class Job < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Statusable
end
