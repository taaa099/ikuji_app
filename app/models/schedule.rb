class Schedule < ApplicationRecord
  belongs_to :child

  validates :start_time, presence: true
  validate :end_time_after_start_time
  validates :title, presence: true, length: { maximum: 50 }
  validates :all_day, inclusion: { in: [ true, false ] }
  VALID_REPEATS = %w[none daily weekly monthly yearly].freeze
  validates :repeat, inclusion: { in: VALID_REPEATS }
  validates :memo, length: { maximum: 200 }

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    if end_time < start_time
      errors.add(:end_time, "は開始時刻以降にしてください")
    end
  end
end
