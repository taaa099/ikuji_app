class Feed < ApplicationRecord
  belongs_to :child

  validate :left_or_right_time_present
  validates :fed_at, presence: true
  
  private

  def left_or_right_time_present
   if (left_time.nil? || left_time == 0) && (right_time.nil? || right_time == 0)
    errors.add(:base, "左右どちらかの授乳時間を1秒以上入力してください")
   end
  end
end
