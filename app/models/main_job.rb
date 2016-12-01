class MainJob < OodJobRails::Job
  belongs_to :container, foreign_key: :workflow_id, inverse_of: :main_job
end
