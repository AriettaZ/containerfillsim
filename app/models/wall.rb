class Wall < Attachment
  belongs_to :container, foreign_key: :workflow_id, inverse_of: :wall
end
