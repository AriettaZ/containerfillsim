class Wall < Attachment
  belongs_to :container, inverse_of: :wall
end
