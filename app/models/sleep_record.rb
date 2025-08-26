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

  after_update :create_default_notification, if: :saved_change_to_end_time?

  def create_default_notification
    return if end_time.blank?

    # リマインダー: 前回の睡眠からの経過時間
    last_sleep = child.sleep_records.where.not(id: id).where.not(end_time: nil).order(end_time: :desc).first
    if last_sleep
      hours_awake = ((start_time - last_sleep.end_time) / 1.hour).round(1)
      if hours_awake >= 3 && hours_awake < 5
        Notification.create!(
          user: user,
          child: child,
          target: self,
          notification_kind: :reminder,
          title: "🛌 睡眠",
          message: "リマインダー: 前回の睡眠から#{hours_awake}時間起きています",
          delivered_at: Time.current
        )
      end
    end

    # アラート: 睡眠の長さチェック
    duration = end_time - start_time
    if duration < 30.minutes || duration > 4.hours
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "🛌 睡眠",
        message: "アラート: 睡眠時間が異常です (#{(duration / 1.hour).round(1)}時間)",
        delivered_at: Time.current
      )
    end
  end
end
