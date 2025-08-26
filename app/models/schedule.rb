class Schedule < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validates :start_time, presence: true
  validates :end_time, presence: true
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

  def create_default_notification
    today = Time.zone.today
    days_until = (start_time.to_date - today).to_i

    # 3日前リマインダー
    if days_until == 3
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "📅 スケジュール",
        message: "リマインダー: 3日後に予定があります (#{title})",
        delivered_at: Time.current
      )
    end

    # 当日アラート
    if days_until == 0
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "📅 スケジュール",
        message: "アラート: 本日の予定があります (#{title})",
        delivered_at: Time.current
      )
    end
  end
end
