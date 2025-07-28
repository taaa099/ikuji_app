class Feed < ApplicationRecord
  belongs_to :child

  validate :left_or_right_time_present

  private

  def left_or_right_time_present
    if left_time.blank? && right_time.blank?
      errors.add(:base, "左右どちらかの授乳時間を入力してください")
    end
  end
end
