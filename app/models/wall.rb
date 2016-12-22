class Wall < OodJobRails::Attachment
  belongs_to :container, foreign_key: :ood_job_rails_workflow_id, inverse_of: :wall
end
