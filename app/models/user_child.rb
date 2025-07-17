class UserChild < ApplicationRecord
  belongs_to :user
  belongs_to :child

  validates :user_id, uniqueness:
  { scope: :child_id, message: "はすでにこの子供に紐づいています" }
end
