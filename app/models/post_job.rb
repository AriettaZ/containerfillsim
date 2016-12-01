class PostJob < OodJobRails::Job
  belongs_to :container, foreign_key: :workflow_id, inverse_of: :post_job
end
