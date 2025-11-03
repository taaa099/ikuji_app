class Schedule < ApplicationRecord
  include Notifiable
  belongs_to :user
  has_many :schedule_children, dependent: :destroy
  has_many :children, through: :schedule_children


  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :must_have_target
  validates :title, presence: true, length: { maximum: 50 }
  validates :all_day, inclusion: { in: [ true, false ] }
  validates :user_only, inclusion: { in: [ true, false ] }
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

  def must_have_target
    if child_ids.blank? && !user_only
      errors.add(:child_ids, "を少なくとも1つ選択してください")
    end
  end
end
