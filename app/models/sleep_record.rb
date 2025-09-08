class SleepRecord < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :validate_start_and_end_time_presence

private

  def validate_start_and_end_time_presence
    if start_time.blank? && end_time.blank?
      errors.add(:start_time, "を入力してください")
      errors.add(:end_time, "を入力してください")
    elsif start_time.blank? && end_time.present?
      errors.add(:start_time, "は必須です。終了時間だけの入力はできません。")
    elsif end_time.present? && end_time < start_time
      errors.add(:end_time, "は開始時間より後でなければなりません。")
    end
  end
end
